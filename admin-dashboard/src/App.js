import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme, CssBaseline, Box } from '@mui/material';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import StationsList from './pages/StationsList';
import StationEdit from './pages/StationEdit';
import PendingApprovals from './pages/PendingApprovals';
import ModerateReviews from './pages/ModerateReviews';
import Reports from './pages/Reports';
import Sidebar from './components/Sidebar';
import Header from './components/Header';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1b5e20',
      light: '#4caf50',
      dark: '#0d3b0f',
    },
    secondary: {
      main: '#1565c0',
      light: '#42a5f5',
      dark: '#0d47a1',
    },
    background: {
      default: '#f5f6fa',
      paper: '#ffffff',
    },
    success: {
      main: '#4caf50',
    },
    warning: {
      main: '#ff9800',
    },
    error: {
      main: '#f44336',
    },
    info: {
      main: '#2196f3',
    },
  },
  typography: {
    fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
  },
  shape: {
    borderRadius: 8,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 600,
        },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderBottomColor: '#f0f0f0',
        },
      },
    },
  },
});

function AuthGuard({ children }) {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
}

function AdminLayout({ children }) {
  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: '#f5f6fa' }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1, ml: 0 }}>
        <Header />
        <Box component="main" sx={{ mt: '64px', minHeight: 'calc(100vh - 64px)' }}>
          {children}
        </Box>
      </Box>
    </Box>
  );
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/dashboard"
        element={
          <AuthGuard>
            <AdminLayout>
              <Dashboard />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/stations"
        element={
          <AuthGuard>
            <AdminLayout>
              <StationsList />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/stations/:id/edit"
        element={
          <AuthGuard>
            <AdminLayout>
              <StationEdit />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/stations/new"
        element={
          <AuthGuard>
            <AdminLayout>
              <StationEdit />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/approvals"
        element={
          <AuthGuard>
            <AdminLayout>
              <PendingApprovals />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/reviews"
        element={
          <AuthGuard>
            <AdminLayout>
              <ModerateReviews />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route
        path="/reports"
        element={
          <AuthGuard>
            <AdminLayout>
              <Reports />
            </AdminLayout>
          </AuthGuard>
        }
      />
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </ThemeProvider>
  );
}
