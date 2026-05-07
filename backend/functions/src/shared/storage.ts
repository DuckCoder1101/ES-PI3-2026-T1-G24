import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions/v2";

const storage = getStorage();
/*
 * Gera URL pública/signed URL do Storage
 */
export const getFileUrl = async (
  path?: string | null,
): Promise<string | null> => {
  try {
    logger.log("Path: " + path);

    if (!path) return null;

    // Caso já seja URL
    if (path.startsWith("http")) {
      return path;
    }

    const file = storage.bucket().file(path);
    const [exists] = await file.exists();

    logger.log("Exists: " + exists);

    if (!exists) {
      return null;
    }

    const [url] = await file.getSignedUrl({
      action: "read",
      expires: "03-01-2500",
    });

    logger.log("Url: " + url);

    return url;
  } catch (err) {
    logger.error("Erro ao buscar file: ");
    logger.error(err);

    return null;
  }
};
