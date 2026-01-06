import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";

const db = admin.firestore();

// Sample course data
const sampleCourses = [
    {
        code: "CS101",
        name: "Introduction to Computer Science",
        description: "Fundamental concepts of programming and computational thinking.",
        credits: 3,
        capacity: 50,
        enrolledCount: 0,
        instructor: "Dr. Sarah Chen",
        schedule: "Mon/Wed 9:00 AM - 10:30 AM",
        semester: "Spring 2026",
    },
    {
        code: "CS201",
        name: "Data Structures and Algorithms",
        description: "Study of data organization, storage, and efficient algorithms.",
        credits: 4,
        capacity: 40,
        enrolledCount: 0,
        instructor: "Prof. Michael Lee",
        schedule: "Tue/Thu 11:00 AM - 12:30 PM",
        semester: "Spring 2026",
    },
    {
        code: "MATH201",
        name: "Calculus II",
        description: "Integral calculus, sequences, series, and applications.",
        credits: 4,
        capacity: 45,
        enrolledCount: 0,
        instructor: "Dr. Emily Watson",
        schedule: "Mon/Wed/Fri 10:00 AM - 11:00 AM",
        semester: "Spring 2026",
    },
    {
        code: "ENG101",
        name: "Academic Writing",
        description: "Fundamentals of academic writing and research methods.",
        credits: 3,
        capacity: 30,
        enrolledCount: 0,
        instructor: "Prof. James Miller",
        schedule: "Tue/Thu 2:00 PM - 3:30 PM",
        semester: "Spring 2026",
    },
    {
        code: "PHYS101",
        name: "Physics I: Mechanics",
        description: "Introduction to classical mechanics, motion, and forces.",
        credits: 4,
        capacity: 40,
        enrolledCount: 0,
        instructor: "Dr. Robert Kim",
        schedule: "Mon/Wed 1:00 PM - 2:30 PM",
        semester: "Spring 2026",
    },
    {
        code: "CS301",
        name: "Database Systems",
        description: "Relational databases, SQL, and database design principles.",
        credits: 3,
        capacity: 35,
        enrolledCount: 0,
        instructor: "Dr. Lisa Park",
        schedule: "Tue/Thu 9:00 AM - 10:30 AM",
        semester: "Spring 2026",
    },
];

/**
 * HTTP Cloud Function to seed the database with sample courses
 * Call this via POST request to initialize your Firestore with course data
 */
export const seedCourses = onRequest(
    { region: "asia-southeast1" },
    async (req, res) => {
        // Only allow POST requests
        if (req.method !== "POST") {
            res.status(405).send("Method Not Allowed. Use POST request.");
            return;
        }

        try {
            // Check if courses already exist
            const existingCourses = await db.collection("courses").limit(1).get();
            if (!existingCourses.empty) {
                res.status(400).json({
                    success: false,
                    message: "Database already contains courses. Clear existing data first.",
                });
                return;
            }

            const batch = db.batch();
            const now = admin.firestore.FieldValue.serverTimestamp();

            for (const course of sampleCourses) {
                const courseRef = db.collection("courses").doc();
                batch.set(courseRef, {
                    ...course,
                    createdAt: now,
                    updatedAt: now,
                });
            }

            await batch.commit();

            console.log(`Successfully seeded ${sampleCourses.length} courses!`);
            res.status(200).json({
                success: true,
                message: `Successfully seeded ${sampleCourses.length} courses!`,
                courses: sampleCourses.map(c => `${c.code}: ${c.name}`),
            });
        } catch (error) {
            console.error("Seeding error:", error);
            res.status(500).json({
                success: false,
                message: "Failed to seed database",
                error: String(error),
            });
        }
    }
);
