import { Request, Response, NextFunction } from "express";
import * as admin from "firebase-admin";

// Extend Express Request to include user info
declare global {
    namespace Express {
        interface Request {
            user?: admin.auth.DecodedIdToken;
        }
    }
}

/**
 * Middleware to validate Firebase ID tokens
 * Extracts and verifies the Bearer token from Authorization header
 */
export async function validateToken(
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        res.status(401).json({ error: "Unauthorized - No token provided" });
        return;
    }

    const idToken = authHeader.split("Bearer ")[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken;
        next();
    } catch (error) {
        console.error("Token verification failed:", error);
        res.status(401).json({ error: "Unauthorized - Invalid token" });
        return;
    }
}
