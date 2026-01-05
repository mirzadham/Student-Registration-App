import { Router, Request, Response } from "express";
import {
    getStudentsCollection,
    createDocument,
    updateDocument,
    getDocumentById,
} from "../utils/firestore.js";

const router = Router();

// Student data interface
interface StudentData {
    email: string;
    name: string;
    // Encrypted fields - stored as ciphertext
    icNumber?: string;       // Encrypted
    phoneNumber?: string;    // Encrypted
    address?: string;        // Encrypted
    emergencyContact?: string; // Encrypted
    dateOfBirth?: string;
    program?: string;
    enrollmentYear?: number;
}

/**
 * POST /register - Register a new student
 * Public endpoint - uses the user's Firebase Auth UID as document ID
 */
router.post("/", async (req: Request, res: Response): Promise<void> => {
    try {
        const { uid, ...studentData } = req.body as StudentData & { uid: string };

        if (!uid || !studentData.email || !studentData.name) {
            res.status(400).json({ error: "Missing required fields: uid, email, name" });
            return;
        }

        // Check if student already exists
        const existingStudent = await getDocumentById(getStudentsCollection(), uid);
        if (existingStudent.exists) {
            res.status(409).json({ error: "Student already registered" });
            return;
        }

        await createDocument(getStudentsCollection(), uid, studentData);

        res.status(201).json({
            message: "Student registered successfully",
            studentId: uid,
        });
    } catch (error) {
        console.error("Error registering student:", error);
        res.status(500).json({ error: "Failed to register student" });
    }
});

/**
 * GET /students/:id - Get student details
 * Protected endpoint - user can only access their own data
 */
router.get("/:id", async (req: Request, res: Response): Promise<void> => {
    try {
        const { id } = req.params;

        // Ensure user can only access their own data
        if (req.user?.uid !== id) {
            res.status(403).json({ error: "Forbidden - Cannot access other student's data" });
            return;
        }

        const studentDoc = await getDocumentById(getStudentsCollection(), id);

        if (!studentDoc.exists) {
            res.status(404).json({ error: "Student not found" });
            return;
        }

        res.status(200).json({
            id: studentDoc.id,
            ...studentDoc.data(),
        });
    } catch (error) {
        console.error("Error fetching student:", error);
        res.status(500).json({ error: "Failed to fetch student details" });
    }
});

/**
 * PUT /students/:id - Update student information
 * Protected endpoint - user can only update their own data
 */
router.put("/:id", async (req: Request, res: Response): Promise<void> => {
    try {
        const { id } = req.params;
        const updateData = req.body as Partial<StudentData>;

        // Ensure user can only update their own data
        if (req.user?.uid !== id) {
            res.status(403).json({ error: "Forbidden - Cannot update other student's data" });
            return;
        }

        // Check if student exists
        const studentDoc = await getDocumentById(getStudentsCollection(), id);
        if (!studentDoc.exists) {
            res.status(404).json({ error: "Student not found" });
            return;
        }

        // Prevent updating email (should be done through Firebase Auth)
        delete updateData.email;

        await updateDocument(getStudentsCollection(), id, updateData);

        res.status(200).json({ message: "Student updated successfully" });
    } catch (error) {
        console.error("Error updating student:", error);
        res.status(500).json({ error: "Failed to update student" });
    }
});

export default router;
