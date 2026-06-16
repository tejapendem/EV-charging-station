import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import DashboardIcon from '@mui/icons-material/Dashboard';
import EvStationIcon from '@mui/icons-material/EvStation';
import RateReviewIcon from '@mui/icons-material/RateReview';
import FlagIcon from '@mui/icons-material/Flag';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import Divider from '@mui/material/Divider';

const DRAWER_WIDTH = 260;

const navItems = [
  { label: 'Dashboard', path: '/dashboard', icon: <DashboardIcon /> },
  { label: 'Stations', path: '/stations', icon: <EvStationIcon /> },
  { label: 'Pending Approvals', path: '/approvals', icon: <VerifiedUserIcon /> },
  { label: 'Moderate Reviews', path: '/reviews', icon: <RateReviewIcon /> },
  { label: 'Reports', path: '/reports', icon: <FlagIcon /> },
];

export default function Sidebar() {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: DRAWER_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: DRAWER_WIDTH,
          boxSizing: 'border-box',
          bgcolor: '#1a1a2e',
          color: '#fff',
          borderRight: 'none',
        },
      }}
    >
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          gap: 1.5,
          px: 2.5,
          py: 2.5,
          borderBottom: '1px solid rgba(255,255,255,0.08)',
        }}
      >
        <Box
          sx={{
            width: 36,
            height: 36,
            borderRadius: 2,
            bgcolor: '#4caf50',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 700,
            fontSize: 18,
            color: '#fff',
          }}
        >
          EV
        </Box>
        <Box>
          <Typography sx={{ fontWeight: 700, fontSize: 16, lineHeight: 1.2 }}>
            EV Connect
          </Typography>
          <Typography sx={{ fontSize: 11, color: 'rgba(255,255,255,0.5)' }}>
            Admin Dashboard
          </Typography>
        </Box>
      </Box>

      <List sx={{ px: 1.5, pt: 1.5 }}>
        {navItems.map((item) => {
          const isActive = location.pathname === item.path || location.pathname.startsWith(item.path + '/');
          return (
            <ListItem key={item.path} disablePadding sx={{ mb: 0.5 }}>
              <ListItemButton
                onClick={() => navigate(item.path)}
                sx={{
                  borderRadius: 2,
                  py: 1.2,
                  px: 2,
                  bgcolor: isActive ? 'rgba(76, 175, 80, 0.15)' : 'transparent',
                  '&:hover': {
                    bgcolor: isActive
                      ? 'rgba(76, 175, 80, 0.2)'
                      : 'rgba(255,255,255,0.05)',
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    minWidth: 38,
                    color: isActive ? '#4caf50' : 'rgba(255,255,255,0.55)',
                  }}
                >
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.label}
                  primaryTypographyProps={{
                    fontSize: 14,
                    fontWeight: isActive ? 600 : 400,
                    color: isActive ? '#fff' : 'rgba(255,255,255,0.7)',
                  }}
                />
              </ListItemButton>
            </ListItem>
          );
        })}
      </List>

      <Divider sx={{ borderColor: 'rgba(255,255,255,0.08)', mx: 2 }} />
    </Drawer>
  );
}
