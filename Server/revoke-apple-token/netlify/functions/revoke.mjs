// Geonaut — Sign in with Apple iznini iptal eden küçük sunucu işlevi (Netlify Functions, ücretsiz).
// Uygulama hesap silinirken buraya Apple'dan aldığı kısa ömürlü "authorization code"u gönderir;
// işlev kodu Apple'a karşılık gizli anahtarla imzalayıp refresh token alır ve onu iptal eder.
// Gizli bilgiler YALNIZCA Netlify ortam değişkenlerinde durur (koda/git'e yazılmaz):
//   APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY (.p8 dosyasının tüm metni), APPLE_CLIENT_ID (com.aspurce.geonaut)
import { createSign } from "node:crypto";

const b64url = (input) => Buffer.from(input).toString("base64url");

function clientSecret({ teamId, keyId, clientId, privateKey }) {
  const now = Math.floor(Date.now() / 1000);
  const header = b64url(JSON.stringify({ alg: "ES256", kid: keyId }));
  const payload = b64url(JSON.stringify({ iss: teamId, iat: now, exp: now + 300, aud: "https://appleid.apple.com", sub: clientId }));
  const signer = createSign("SHA256");
  signer.update(`${header}.${payload}`);
  const signature = signer.sign({ key: privateKey, dsaEncoding: "ieee-p1363" }).toString("base64url");
  return `${header}.${payload}.${signature}`;
}

async function appleForm(path, fields) {
  const res = await fetch(`https://appleid.apple.com/auth/${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams(fields),
  });
  const text = await res.text();
  return { ok: res.ok, status: res.status, body: text };
}

export default async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });

  const { APPLE_TEAM_ID: teamId, APPLE_KEY_ID: keyId, APPLE_CLIENT_ID: clientId } = process.env;
  const privateKey = (process.env.APPLE_PRIVATE_KEY || "").replace(/\\n/g, "\n");
  if (!teamId || !keyId || !clientId || !privateKey) return new Response("Server not configured", { status: 500 });

  let code;
  try { ({ code } = await req.json()); } catch { return new Response("Bad request", { status: 400 }); }
  if (typeof code !== "string" || code.length < 10 || code.length > 2000) return new Response("Bad request", { status: 400 });

  const secret = clientSecret({ teamId, keyId, clientId, privateKey });
  const token = await appleForm("token", { client_id: clientId, client_secret: secret, code, grant_type: "authorization_code" });
  if (!token.ok) return new Response("Token exchange failed", { status: 502 });

  const { refresh_token: refreshToken } = JSON.parse(token.body);
  if (!refreshToken) return new Response("No refresh token", { status: 502 });

  const revoke = await appleForm("revoke", { client_id: clientId, client_secret: secret, token: refreshToken, token_type_hint: "refresh_token" });
  return new Response(revoke.ok ? "ok" : "Revoke failed", { status: revoke.ok ? 200 : 502 });
};

export const config = { path: "/revoke" };
