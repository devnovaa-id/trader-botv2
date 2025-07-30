
const ADMIN_USERNAME = process.env.NEXT_PUBLIC_ADMIN_USERNAME || 'admin'
const ADMIN_PASSWORD = process.env.NEXT_PUBLIC_ADMIN_PASSWORD || 'password'

export const authConfig = {
  ADMIN_USERNAME,
  ADMIN_PASSWORD,
  COOKIE_NAME: 'airo-auth-session',
  REMEMBER_ME_DURATION: 24 * 60 * 60 * 1000, // 1 day in milliseconds
  SESSION_DURATION: 60 * 60 * 1000 // 1 hour in milliseconds
}

export function generateSessionToken(username, rememberMe = false) {
  const sessionData = {
    username,
    loginTime: Date.now(),
    expiresAt: Date.now() + (rememberMe ? authConfig.REMEMBER_ME_DURATION : authConfig.SESSION_DURATION)
  }
  
  // Simple base64 encoding (not for security, just for storage)
  return btoa(JSON.stringify(sessionData))
}

export function verifySessionToken(token) {
  try {
    const sessionData = JSON.parse(atob(token))
    const now = Date.now()
    
    if (sessionData.expiresAt > now && sessionData.username === authConfig.ADMIN_USERNAME) {
      return sessionData
    }
    return null
  } catch (error) {
    return null
  }
}

export function validateCredentials(username, password) {
  return username === ADMIN_USERNAME && password === ADMIN_PASSWORD
}

export function isSessionValid(token) {
  const sessionData = verifySessionToken(token)
  return sessionData !== null
}

// Browser-side authentication helpers
export const clientAuth = {
  setAuthCookie(token, rememberMe = false) {
    const expires = rememberMe 
      ? new Date(Date.now() + authConfig.REMEMBER_ME_DURATION) 
      : new Date(Date.now() + authConfig.SESSION_DURATION)
    document.cookie = `${authConfig.COOKIE_NAME}=${token}; expires=${expires.toUTCString()}; path=/; secure; samesite=strict`
  },

  getAuthCookie() {
    if (typeof document === 'undefined') return null
    
    const cookies = document.cookie.split(';')
    const authCookie = cookies.find(cookie => cookie.trim().startsWith(`${authConfig.COOKIE_NAME}=`))
    
    if (!authCookie) return null
    
    return authCookie.split('=')[1]
  },

  removeAuthCookie() {
    document.cookie = `${authConfig.COOKIE_NAME}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`
  },

  isAuthenticated() {
    const token = this.getAuthCookie()
    return token && isSessionValid(token)
  },

  logout() {
    this.removeAuthCookie()
    window.location.href = '/login'
  }
}
