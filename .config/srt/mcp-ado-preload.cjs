// Preloaded into the sandboxed ADO MCP server (NODE_OPTIONS=--require=...).
// srt's local proxy requires Proxy-Authorization and puts the credentials in
// HTTPS_PROXY's userinfo. @azure-devops/mcp's HTTP stack (typed-rest-client ->
// tunnel) ignores URL userinfo, so every API call fails with HTTP 407. Inject
// the credentials into tunnel's proxy options; they only authenticate to the
// local srt proxy.
const Module = require("module");
const load = Module._load;

function proxyAuth() {
  const raw = process.env.HTTPS_PROXY || process.env.https_proxy || process.env.HTTP_PROXY || process.env.http_proxy;
  if (!raw) return undefined;
  try {
    const u = new URL(raw);
    if (!u.username) return undefined;
    return decodeURIComponent(u.username) + ":" + decodeURIComponent(u.password);
  } catch {
    return undefined;
  }
}

Module._load = function (request, ...rest) {
  const mod = load.call(this, request, ...rest);
  if (request === "tunnel" && mod && !mod.__srtPatched) {
    Object.defineProperty(mod, "__srtPatched", { value: true });
    for (const name of ["httpOverHttp", "httpsOverHttp", "httpOverHttps", "httpsOverHttps"]) {
      const fn = mod[name];
      if (typeof fn !== "function") continue;
      mod[name] = function (options) {
        if (options && options.proxy && !options.proxy.proxyAuth) {
          const auth = proxyAuth();
          if (auth) options.proxy.proxyAuth = auth;
        }
        return fn.call(this, options);
      };
    }
  }
  return mod;
};
