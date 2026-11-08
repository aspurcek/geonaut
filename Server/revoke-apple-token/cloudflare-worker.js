// Geonaut — Sign in with Apple iznini iptal eden küçük sunucu işlevi (Cloudflare Workers, ücretsiz).
// Netlify sürümüyle (netlify/functions/revoke.mjs) aynı işi yapar; Netlify'ın kredi sistemi yüzünden bu sürüm tercih edildi.
// Uygulama hesap silinirken buraya Apple'dan aldığı kısa ömürlü "authorization code"u POST eder ({"code": "..."}).
// Gizli bilgiler YALNIZCA Cloudflare'in "Variables and Secrets" bölümünde durur (koda/git'e yazılmaz):
//   APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_CLIENT_ID (com.aspurce.geonaut), APPLE_PRIVATE_KEY (.p8 dosyasının tüm metni)

const b64url = (bytes) => btoa(String.fromCharCode(...new Uint8Array(bytes))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
const encode = (obj) => b64url(new TextEncoder().encode(JSON.stringify(obj)));

async function clientSecret({ teamId, keyId, clientId, privateKeyPem }) {
  const pem = privateKeyPem.replace(/\\n/g, "\n").replace(/-----(BEGIN|END) PRIVATE KEY-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey("pkcs8", der, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
  const now = Math.floor(Date.now() / 1000);
  const signingInput = `${encode({ alg: "ES256", kid: keyId })}.${encode({ iss: teamId, iat: now, exp: now + 300, aud: "https://appleid.apple.com", sub: clientId })}`;
  const signature = await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(signingInput));
  return `${signingInput}.${b64url(signature)}`;
}

async function appleForm(path, fields) {
  const res = await fetch(`https://appleid.apple.com/auth/${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams(fields),
  });
  return { ok: res.ok, status: res.status, body: await res.text() };
}

export default {
  async fetch(request, env) {
    if (request.method !== "POST") return new Response("Method Not Allowed", { status: 405 });
    const { APPLE_TEAM_ID: teamId, APPLE_KEY_ID: keyId, APPLE_CLIENT_ID: clientId, APPLE_PRIVATE_KEY: privateKeyPem } = env;
    if (!teamId || !keyId || !clientId || !privateKeyPem) return new Response("Server not configured", { status: 500 });

    let code;
    try { ({ code } = await request.json()); } catch { return new Response("Bad request", { status: 400 }); }
    if (typeof code !== "string" || code.length < 10 || code.length > 2000) return new Response("Bad request", { status: 400 });

    let secret;
    try { secret = await clientSecret({ teamId, keyId, clientId, privateKeyPem }); } catch { return new Response("Bad key", { status: 500 }); }
    const token = await appleForm("token", { client_id: clientId, client_secret: secret, code, grant_type: "authorization_code" });
    if (!token.ok) return new Response("Token exchange failed", { status: 502 });

    let refreshToken;
    try { refreshToken = JSON.parse(token.body).refresh_token; } catch { /* aşağıda ele alınır */ }
    if (!refreshToken) return new Response("No refresh token", { status: 502 });

    const revoke = await appleForm("revoke", { client_id: clientId, client_secret: secret, token: refreshToken, token_type_hint: "refresh_token" });
    return new Response(revoke.ok ? "ok" : "Revoke failed", { status: revoke.ok ? 200 : 502 });
  },
};
