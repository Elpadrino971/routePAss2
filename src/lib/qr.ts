import jwt from 'jsonwebtoken';

interface ProviderQRPayload {
  v: 1;
  kind: 'provider';
  pid: string; // provider.id
  iat?: number;
}

interface AccessQRPayload {
  v: 1;
  kind: 'access';
  bid: string; // booking.id
  aid: string; // asset.id
  exp?: number;
}

export type QRPayload = ProviderQRPayload | AccessQRPayload;

function secret(): string {
  const s = process.env.QR_SECRET;
  if (!s) throw new Error('QR_SECRET manquant');
  return s;
}

/** Génère un QR signé pour un prestataire (sans expiration — long-lived). */
export function signProviderQR(providerId: string): string {
  const payload: ProviderQRPayload = { v: 1, kind: 'provider', pid: providerId };
  return jwt.sign(payload, secret());
}

/** Génère un QR d'accès signé pour une réservation (expiration = end_at). */
export function signAccessQR(
  bookingId: string,
  assetId: string,
  endAt: Date
): string {
  const payload: AccessQRPayload = {
    v: 1,
    kind: 'access',
    bid: bookingId,
    aid: assetId,
  };
  return jwt.sign(payload, secret(), {
    expiresIn: Math.max(60, Math.floor((endAt.getTime() - Date.now()) / 1000)),
  });
}

/** Décode et vérifie un QR ROUTEPASS. */
export function verifyQR(token: string): QRPayload {
  const decoded = jwt.verify(token, secret());
  if (typeof decoded === 'string') throw new Error('Token QR invalide');
  return decoded as QRPayload;
}
