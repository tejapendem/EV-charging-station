import React, { useState, useEffect } from 'react';
import {
  Box,
  Grid,
  Typography,
  Paper,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  Avatar,
  Skeleton,
} from '@mui/material';
import EvStationIcon from '@mui/icons-material/EvStation';
import PeopleIcon from '@mui/icons-material/People';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import ReportIcon from '@mui/icons-material/Report';
import BatteryChargingFullIcon from '@mui/icons-material/BatteryChargingFull';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import NewReleasesIcon from '@mui/icons-material/NewReleases';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
  AreaChart,
  Area,
} from 'recharts';
import StatCard from '../components/StatCard';
import { analyticsAPI } from '../services/api';

const CHARGER_COLORS = ['#4caf50', '#2196f3', '#ff9800', '#9c27b0', '#f44336', '#00bcd4'];

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const { data: dashboard } = await analyticsAPI.getDashboard();
        const { data: stationsTimeline } = await analyticsAPI.getStationsTimeline('monthly');
        const { data: userGrowth } = await analyticsAPI.getUserGrowth('monthly');
        const { data: chargerTypes } = await analyticsAPI.getChargerTypes();
        setData({ dashboard, stationsTimeline, userGrowth, chargerTypes });
      } catch (err) {
        setData({
          dashboard: {
            totalStations: 0,
            totalUsers: 0,
            pendingApprovals: 0,
            totalReports: 0,
            recentActivity: [],
          },
          stationsTimeline: [],
          userGrowth: [],
          chargerTypes: [],
        });
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <Box sx={{ p: 3 }}>
        <Grid container spacing={3}>
          {[1, 2, 3, 4].map((i) => (
            <Grid item xs={12} sm={6} md={3} key={i}>
              <Skeleton variant="rounded" height={120} sx={{ borderRadius: 3 }} />
            </Grid>
          ))}
        </Grid>
      </Box>
    );
  }

  const stats = [
    {
      title: 'Total Stations',
      value: data.dashboard?.totalStations ?? 0,
      icon: <EvStationIcon sx={{ fontSize: 26 }} />,
      color: '#4caf50',
    },
    {
      title: 'Total Users',
      value: data.dashboard?.totalUsers ?? 0,
      icon: <PeopleIcon sx={{ fontSize: 26 }} />,
      color: '#2196f3',
    },
    {
      title: 'Pending Approvals',
      value: data.dashboard?.pendingApprovals ?? 0,
      icon: <PendingActionsIcon sx={{ fontSize: 26 }} />,
      color: '#ff9800',
    },
    {
      title: 'Reports',
      value: data.dashboard?.totalReports ?? 0,
      icon: <ReportIcon sx={{ fontSize: 26 }} />,
      color: '#f44336',
    },
  ];

  const timeline =
    data.stationsTimeline?.length > 0
      ? data.stationsTimeline
      : [
          { month: 'Jan', stations: 4 },
          { month: 'Feb', stations: 7 },
          { month: 'Mar', stations: 5 },
          { month: 'Apr', stations: 12 },
          { month: 'May', stations: 9 },
          { month: 'Jun', stations: 15 },
        ];

  const growth =
    data.userGrowth?.length > 0
      ? data.userGrowth
      : [
          { month: 'Jan', users: 120 },
          { month: 'Feb', users: 250 },
          { month: 'Mar', users: 380 },
          { month: 'Apr', users: 520 },
          { month: 'May', users: 690 },
          { month: 'Jun', users: 850 },
        ];

  const chargers =
    data.chargerTypes?.length > 0
      ? data.chargerTypes
      : [
          { name: 'CCS2', value: 45 },
          { name: 'CHAdeMO', value: 20 },
          { name: 'Type 2', value: 25 },
          { name: 'GB/T', value: 10 },
        ];

  const activityIcons = {
    station_added: <EvStationIcon fontSize="small" />,
    user_joined: <PersonAddIcon fontSize="small" />,
    review_added: <CheckCircleIcon fontSize="small" />,
    report_filed: <NewReleasesIcon fontSize="small" />,
  };

  const activityColors = {
    station_added: '#4caf50',
    user_joined: '#2196f3',
    review_added: '#ff9800',
    report_filed: '#f44336',
  };

  const activities =
    data.dashboard?.recentActivity?.length > 0
      ? data.dashboard.recentActivity
      : [
          { type: 'station_added', message: 'New station added in Bangalore', time: '2 min ago' },
          { type: 'user_joined', message: 'New user registered', time: '15 min ago' },
          { type: 'review_added', message: 'New review submitted for MG Motors', time: '1 hour ago' },
          { type: 'report_filed', message: 'Report filed for Station #42', time: '2 hours ago' },
          { type: 'station_added', message: 'Station approved in Chennai', time: '3 hours ago' },
        ];

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3, color: '#1a1a2e' }}>
        Dashboard Overview
      </Typography>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <StatCard {...stat} />
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2, color: '#1a1a2e' }}>
              Stations Added Over Time
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={timeline}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: 8,
                    border: 'none',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                  }}
                />
                <Bar dataKey="stations" fill="#4caf50" radius={[6, 6, 0, 0]} barSize={40} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)', height: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2, color: '#1a1a2e' }}>
              Charger Types
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={chargers}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={90}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {chargers.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={CHARGER_COLORS[index % CHARGER_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    borderRadius: 8,
                    border: 'none',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                  }}
                />
                <Legend
                  verticalAlign="bottom"
                  wrapperStyle={{ fontSize: 12 }}
                />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2, color: '#1a1a2e' }}>
              User Growth
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={growth}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: 8,
                    border: 'none',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                  }}
                />
                <defs>
                  <linearGradient id="userGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#4caf50" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#4caf50" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <Area
                  type="monotone"
                  dataKey="users"
                  stroke="#4caf50"
                  strokeWidth={2}
                  fill="url(#userGradient)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)', height: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2, color: '#1a1a2e' }}>
              Recent Activity
            </Typography>
            <List disablePadding>
              {activities.map((activity, i) => (
                <ListItem key={i} disableGutters sx={{ px: 0, py: 1 }}>
                  <ListItemAvatar sx={{ minWidth: 44 }}>
                    <Avatar
                      sx={{
                        width: 32,
                        height: 32,
                        bgcolor: `${activityColors[activity.type] || '#999'}20`,
                        color: activityColors[activity.type] || '#999',
                      }}
                    >
                      {activityIcons[activity.type] || <CheckCircleIcon fontSize="small" />}
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={activity.message}
                    secondary={activity.time}
                    primaryTypographyProps={{ fontSize: 13, fontWeight: 500 }}
                    secondaryTypographyProps={{ fontSize: 11 }}
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
