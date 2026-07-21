import { createContext, useContext, useMemo, useState } from 'react';
import { api } from './api';
const AuthContext = createContext(null);
export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('myfs-user'));
    } catch {
      return null;
    }
  });
  const login = async (phone, password) => {
    const data = await api.post('/api/auth/login', { phone, password });
    if (!['ADMIN', 'TEACHER'].includes(data.role))
      throw new Error('Tài khoản này chỉ sử dụng ứng dụng mobile');
    localStorage.setItem('myfs-user', JSON.stringify(data.user));
    setUser(data.user);
    return data;
  };
  const logout = () => {
    localStorage.removeItem('myfs-user');
    setUser(null);
  };
  const value = useMemo(() => ({ user, login, logout }), [user]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
export const useAuth = () => useContext(AuthContext);
