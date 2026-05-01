/**
 * Wrapper TTLock — gestion des serrures connectées via API Cloud TTLock (euapi).
 * Doc : https://euopen.ttlock.com
 *
 * Toutes les fonctions s'exécutent côté serveur uniquement.
 */

const BASE = 'https://euapi.ttlock.com';

interface TokenCache {
  accessToken: string;
  expiresAt: number;
}

let tokenCache: TokenCache | null = null;

/** MD5 du mot de passe (TTLock impose un MD5 hex lowercase). */
async function md5Hex(input: string): Promise<string> {
  const { createHash } = await import('node:crypto');
  return createHash('md5').update(input, 'utf8').digest('hex');
}

async function getAccessToken(): Promise<string> {
  if (tokenCache && tokenCache.expiresAt > Date.now() + 60_000) {
    return tokenCache.accessToken;
  }
  const clientId = process.env.TTLOCK_CLIENT_ID;
  const clientSecret = process.env.TTLOCK_CLIENT_SECRET;
  const username = process.env.TTLOCK_USERNAME;
  const password = process.env.TTLOCK_PASSWORD;
  if (!clientId || !clientSecret || !username || !password) {
    throw new Error('TTLock non configuré');
  }

  const body = new URLSearchParams({
    clientId,
    clientSecret,
    username,
    password: await md5Hex(password),
  });

  const res = await fetch(`${BASE}/oauth2/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) throw new Error(`TTLock auth: ${res.status}`);
  const json = (await res.json()) as { access_token: string; expires_in: number };
  tokenCache = {
    accessToken: json.access_token,
    expiresAt: Date.now() + json.expires_in * 1000,
  };
  return json.access_token;
}

/** Active une carte NFC pour la fenêtre [now, endTime]. */
export async function activateNFCCard(
  lockId: string,
  cardNumber: string,
  endTime: Date
): Promise<void> {
  const accessToken = await getAccessToken();
  const body = new URLSearchParams({
    clientId: process.env.TTLOCK_CLIENT_ID!,
    accessToken,
    lockId,
    cardNumber,
    startDate: Date.now().toString(),
    endDate: endTime.getTime().toString(),
    addType: '2',
  });
  const res = await fetch(`${BASE}/v3/identityCard/add`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) throw new Error(`TTLock activate: ${res.status}`);
}

/** Désactive une carte NFC. */
export async function deactivateNFCCard(
  lockId: string,
  cardNumber: string
): Promise<void> {
  const accessToken = await getAccessToken();
  const body = new URLSearchParams({
    clientId: process.env.TTLOCK_CLIENT_ID!,
    accessToken,
    lockId,
    cardNumber,
  });
  const res = await fetch(`${BASE}/v3/identityCard/delete`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) throw new Error(`TTLock deactivate: ${res.status}`);
}
