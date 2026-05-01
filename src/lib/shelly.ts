/**
 * Wrapper Shelly — pilotage de l'électricité via Shelly Cloud REST API.
 * Doc : https://shelly-api-docs.shelly.cloud/cloud-control-api/
 */

async function call(path: string, params: Record<string, string>): Promise<void> {
  const auth = process.env.SHELLY_AUTH_KEY;
  const server = process.env.SHELLY_SERVER_URI ?? 'https://shelly-api-eu.shelly.cloud';
  if (!auth) throw new Error('Shelly non configuré');
  const body = new URLSearchParams({ ...params, auth_key: auth });
  const res = await fetch(`${server}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) throw new Error(`Shelly ${path}: ${res.status}`);
}

/** Allume le relais 0 du device. */
export async function powerOn(deviceId: string): Promise<void> {
  await call('/device/relay/control', {
    id: deviceId,
    channel: '0',
    turn: 'on',
  });
}

/** Coupe le relais 0 du device. */
export async function powerOff(deviceId: string): Promise<void> {
  await call('/device/relay/control', {
    id: deviceId,
    channel: '0',
    turn: 'off',
  });
}
