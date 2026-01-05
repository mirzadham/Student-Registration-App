import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import express, { Request, Response, NextFunction } from "express";
import cors from "cors";

import { validateToken } from "./middleware/auth.js";
import studentsRouter from "./routes/students.js";
import coursesRouter from "./routes/courses.js";
import enrollmentsRouter from "./routes/enrollments.js";

// Set global options - region to asia-southeast1 (Singapore)
setGlobalOptions({ region: "asia-southeast1" });

// Initialize Firebase Admin
admin.initializeApp();

// Create Express app
const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());

// Health check endpoint (public)
app.get("/health", (_req: Request, res: Response) => {
    res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

// Protected routes - require authentication
app.use("/students", validateToken, studentsRouter);
app.use("/courses", validateToken, coursesRouter);
app.use("/enrollments", validateToken, enrollmentsRouter);

// Public registration endpoint
app.post("/register", studentsRouter);

// Error handling middleware
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
    console.error("Error:", err.message);
    res.status(500).json({
        error: "Internal server error",
        message: process.env.NODE_ENV === "development" ? err.message : undefined
    });
});

// Export the Express app as a Firebase Cloud Function
export const api = onRequest(app);

