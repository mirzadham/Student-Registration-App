import { Router, Request, Response } from "express";
import { getCoursesCollection, queryCollection } from "../utils/firestore.js";

const router = Router();

// Course data interface
interface CourseData {
    code: string;
    name: string;
    description?: string;
    credits: number;
    capacity: number;
    enrolledCount: number;
    instructor?: string;
    schedule?: string;
    semester?: string;
}

/**
 * GET /courses - List all available courses
 * Protected endpoint - any authenticated user can view courses
 */
router.get("/", async (_req: Request, res: Response): Promise<void> => {
    try {
        const coursesSnapshot = await queryCollection(getCoursesCollection());

        const courses = coursesSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data() as CourseData,
            availableSlots: (doc.data().capacity || 0) - (doc.data().enrolledCount || 0),
        }));

        res.status(200).json({ courses });
    } catch (error) {
        console.error("Error fetching courses:", error);
        res.status(500).json({ error: "Failed to fetch courses" });
    }
});

/**
 * GET /courses/:id - Get course details
 * Protected endpoint - any authenticated user can view course details
 */
router.get("/:id", async (req: Request, res: Response): Promise<void> => {
    try {
        const { id } = req.params;
        const courseDoc = await getCoursesCollection().doc(id).get();

        if (!courseDoc.exists) {
            res.status(404).json({ error: "Course not found" });
            return;
        }

        const courseData = courseDoc.data() as CourseData;
        res.status(200).json({
            id: courseDoc.id,
            ...courseData,
            availableSlots: (courseData.capacity || 0) - (courseData.enrolledCount || 0),
        });
    } catch (error) {
        console.error("Error fetching course:", error);
        res.status(500).json({ error: "Failed to fetch course details" });
    }
});

export default router;
