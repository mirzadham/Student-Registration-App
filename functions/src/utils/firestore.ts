import * as admin from "firebase-admin";

// Lazy initialization - Firestore instance is created on first access
// This ensures admin.initializeApp() has been called in index.ts first
let _db: admin.firestore.Firestore | null = null;

function getDb(): admin.firestore.Firestore {
    if (!_db) {
        _db = admin.firestore();
    }
    return _db;
}

// Collection getters - lazy loaded to avoid initialization order issues
export function getStudentsCollection(): admin.firestore.CollectionReference {
    return getDb().collection("students");
}

export function getCoursesCollection(): admin.firestore.CollectionReference {
    return getDb().collection("courses");
}

export function getEnrollmentsCollection(): admin.firestore.CollectionReference {
    return getDb().collection("enrollments");
}

export function getAcademicRecordsCollection(): admin.firestore.CollectionReference {
    return getDb().collection("academic_records");
}

/**
 * Get a document by ID from a collection
 */
export async function getDocumentById(
    collection: admin.firestore.CollectionReference,
    id: string
): Promise<admin.firestore.DocumentSnapshot> {
    return collection.doc(id).get();
}

/**
 * Create a new document with a specific ID
 */
export async function createDocument(
    collection: admin.firestore.CollectionReference,
    id: string,
    data: admin.firestore.DocumentData
): Promise<admin.firestore.WriteResult> {
    return collection.doc(id).set({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

/**
 * Update an existing document
 */
export async function updateDocument(
    collection: admin.firestore.CollectionReference,
    id: string,
    data: admin.firestore.DocumentData
): Promise<admin.firestore.WriteResult> {
    return collection.doc(id).update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

/**
 * Delete a document by ID
 */
export async function deleteDocument(
    collection: admin.firestore.CollectionReference,
    id: string
): Promise<admin.firestore.WriteResult> {
    return collection.doc(id).delete();
}

/**
 * Get all documents from a collection with optional query
 */
export async function queryCollection(
    collection: admin.firestore.CollectionReference,
    field?: string,
    operator?: admin.firestore.WhereFilterOp,
    value?: unknown
): Promise<admin.firestore.QuerySnapshot> {
    if (field && operator && value !== undefined) {
        return collection.where(field, operator, value).get();
    }
    return collection.get();
}
