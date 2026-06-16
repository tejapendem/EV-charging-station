import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import Badge from '@mui/material/Badge';
import Avatar from '@mui/material/Avatar';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import Box from '@mui/material/Box';
import NotificationsIcon from '@mui/icons-material/Notifications';
import LogoutIcon from '@mui/icons-material/Logout';
import SettingsIcon from '@mui/icons-material/Settings';
import PersonIcon from '@mui/icons-material/Person';

export default function Header() {
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState(null);

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    navigate('/login');
  };

  return (
    <AppBar
      position="fixed"
      elevation={0}
      sx={{
        bgcolor: '#fff',
        color: '#1a1a2e',
        borderBottom: '1px solid #e8e8e8',
        ml: '260px',
        width: 'calc(100% - 260px)',
      }}
    >
      <Toolbar sx={{ justifyContent: 'flex-end', gap: 1 }}>
        <Typography variant="body2" color="text.secondary" sx={{ mr: 'auto' }}>
          Welcome back, Admin
        </Typography>

        <IconButton size="small">
          <Badge badgeContent={3} color="error">
            <NotificationsIcon sx={{ fontSize: 22, color: '#666' }} />
          </Badge>
        </IconButton>

        <IconButton size="small" onClick={(e) => setAnchorEl(e.currentTarget)}>
          <Avatar
            sx={{
              width: 34,
              height: 34,
              bgcolor: '#1b5e20',
              fontSize: 14,
              fontWeight: 600,
            }}
          >
            A
          </Avatar>
        </IconButton>

        <Menu
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={() => setAnchorEl(null)}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          PaperProps={{
            sx: { borderRadius: 2, minWidth: 200, mt: 1 },
          }}
        >
          <MenuItem onClick={() => { setAnchorEl(null); }}>
            <ListItemIcon><PersonIcon fontSize="small" /></ListItemIcon>
            Profile
          </MenuItem>
          <MenuItem onClick={() => { setAnchorEl(null); }}>
            <ListItemIcon><SettingsIcon fontSize="small" /></ListItemIcon>
            Settings
          </MenuItem>
          <MenuItem onClick={handleLogout}>
            <ListItemIcon><LogoutIcon fontSize="small" /></ListItemIcon>
            Logout
          </MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  );
}
