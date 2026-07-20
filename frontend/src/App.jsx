import { Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth';
import { Layout } from './components';
import Login from './pages/Login';
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminManagement from './pages/admin/AdminManagement';
import TeacherDashboard from './pages/teacher/TeacherDashboard';
import TeacherWorkspace from './pages/teacher/TeacherWorkspace';

function Guard({ role, children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  if (user.role !== role)
    return <Navigate to={user.role === 'ADMIN' ? '/admin' : '/teacher'} replace />;
  return <Layout>{children}</Layout>;
}
function Router() {
  const { user } = useAuth();
  return (
    <Routes>
      <Route
        path="/login"
        element={
          user ? <Navigate to={user.role === 'ADMIN' ? '/admin' : '/teacher'} replace /> : <Login />
        }
      />
      <Route
        path="/admin"
        element={
          <Guard role="ADMIN">
            <AdminDashboard />
          </Guard>
        }
      />
      <Route path="/admin/users" element={<Navigate to="/admin/teachers" replace />} />
      <Route
        path="/admin/:section"
        element={
          <Guard role="ADMIN">
            <AdminManagement />
          </Guard>
        }
      />
      <Route
        path="/teacher"
        element={
          <Guard role="TEACHER">
            <TeacherDashboard />
          </Guard>
        }
      />
      <Route
        path="/teacher/:section"
        element={
          <Guard role="TEACHER">
            <TeacherWorkspace />
          </Guard>
        }
      />
      <Route
        path="*"
        element={
          <Navigate
            to={user ? (user.role === 'ADMIN' ? '/admin' : '/teacher') : '/login'}
            replace
          />
        }
      />
    </Routes>
  );
}
export default function App() {
  return (
    <AuthProvider>
      <Router />
    </AuthProvider>
  );
}
