import { Router, Request, Response } from "express";
import * as admin from "firebase-admin";
import {
    getEnrollmentsCollection,
    getCoursesCollection,
    getStudentsCollection,
    createDocument,
    queryCollection,
    getDocumentById,
} from "../utils/firestore.js";

const router = Router();

// Enrollment data interface
interface EnrollmentData {
    studentId: string;
    courseId: string;
    courseName?: string;
    courseCode?: string;
    status: "enrolled" | "dropped" | "completed";
    enrolledAt?: admin.firestore.Timestamp;
}

/**
 * POST /enrollments/enroll - Enroll student in a course
 * Protected endpoint - user can only enroll themselves
 */
router.post("/enroll", async (req: Request, res: Response): Promise<void> => {
    try {
        const { courseId } = req.body;
        const studentId = req.user?.uid;

        if (!studentId || !courseId) {
            res.status(400).json({ error: "Missing required fields: courseId" });
            return;
        }

        // Check if student exists
        const studentDoc = await getDocumentById(getStudentsCollection(), studentId);
        if (!studentDoc.exists) {
            res.status(404).json({ error: "Student not found. Please complete registration first." });
            return;
        }

        // Check if course exists
        const courseDoc = await getCoursesCollection().doc(courseId).get();
        if (!courseDoc.exists) {
            res.status(404).json({ error: "Course not found" });
            return;
        }

        const courseData = courseDoc.data();
        const capacity = courseData?.capacity || 0;
        const enrolledCount = courseData?.enrolledCount || 0;

        // Check course capacity
        if (enrolledCount >= capacity) {
            res.status(400).json({ error: "Course is full" });
            return;
        }

        // Check if already enrolled
        const existingEnrollment = await queryCollection(
            getEnrollmentsCollection(),
            "studentId",
            "==",
            studentId
        );

        const alreadyEnrolled = existingEnrollment.docs.some(
            (doc) => doc.data().courseId === courseId && doc.data().status === "enrolled"
        );

        if (alreadyEnrolled) {
            res.status(409).json({ error: "Already enrolled in this course" });
            return;
        }

        // Create enrollment
        const enrollmentId = `${studentId}_${courseId}`;
        const enrollmentData: EnrollmentData = {
            studentId,
            courseId,
            courseName: courseData?.name,
            courseCode: courseData?.code,
            status: "enrolled",
        };

        await createDocument(getEnrollmentsCollection(), enrollmentId, enrollmentData);

        // Update course enrolled count
        await getCoursesCollection().doc(courseId).update({
            enrolledCount: admin.firestore.FieldValue.increment(1),
        });

        res.status(201).json({
            message: "Enrolled successfully",
            enrollmentId,
        });
    } catch (error) {
        console.error("Error enrolling student:", error);
        res.status(500).json({ error: "Failed to enroll in course" });
    }
});

/**
 * GET /enrollments/student/:studentId - Get student's enrollments
 * Protected endpoint - user can only view their own enrollments
 */
router.get("/student/:studentId", async (req: Request, res: Response): Promise<void> => {
    try {
        const { studentId } = req.params;

        // Ensure user can only access their own enrollments
        if (req.user?.uid !== studentId) {
            res.status(403).json({ error: "Forbidden - Cannot access other student's enrollments" });
            return;
        }

        const enrollmentsSnapshot = await queryCollection(
            getEnrollmentsCollection(),
            "studentId",
            "==",
            studentId
        );

        const enrollments = enrollmentsSnapshot.docs
            .filter((doc) => doc.data().status === "enrolled")
            .map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));

        res.status(200).json({ enrollments });
    } catch (error) {
        console.error("Error fetching enrollments:", error);
        res.status(500).json({ error: "Failed to fetch enrollments" });
    }
});

/**
 * DELETE /enrollments/:id - Drop a course (unenroll)
 * Protected endpoint - user can only drop their own enrollments
 */
router.delete("/:id", async (req: Request, res: Response): Promise<void> => {
    try {
        const { id } = req.params;
        const studentId = req.user?.uid;

        // Get enrollment to verify ownership
        const enrollmentDoc = await getEnrollmentsCollection().doc(id).get();

        if (!enrollmentDoc.exists) {
            res.status(404).json({ error: "Enrollment not found" });
            return;
        }

        const enrollmentData = enrollmentDoc.data() as EnrollmentData;

        // Ensure user can only drop their own enrollments
        if (enrollmentData.studentId !== studentId) {
            res.status(403).json({ error: "Forbidden - Cannot drop other student's enrollment" });
            return;
        }

        // Update enrollment status instead of deleting (for record keeping)
        await getEnrollmentsCollection().doc(id).update({
            status: "dropped",
            droppedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Decrease course enrolled count
        await getCoursesCollection().doc(enrollmentData.courseId).update({
            enrolledCount: admin.firestore.FieldValue.increment(-1),
        });

        res.status(200).json({ message: "Course dropped successfully" });
    } catch (error) {
        console.error("Error dropping course:", error);
        res.status(500).json({ error: "Failed to drop course" });
    }
});

export default router;
