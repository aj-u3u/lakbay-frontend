import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router';
import { ThemeProvider } from './components/ThemeContext';
import { BottomNav } from './components/BottomNav';

import { LandingPage } from './pages/LandingPage';
import { LoginPage } from './pages/LoginPage';
import { SignupPage } from './pages/SignupPage';
import { HomePage } from './pages/HomePage';
import { NotificationsPage } from './pages/NotificationsPage';
import { FilterPage } from './pages/FilterPage';
import { ShowAllPage } from './pages/ShowAllPage';
import { FilteredResultsPage } from './pages/FilteredResultsPage';
import { DestinationDetailsPage } from './pages/DestinationDetailsPage';
import { AIPlannerPage } from './pages/AIPlannerPage';
import { CustomizeItineraryPage } from './pages/CustomizeItineraryPage';
import { TripsPage } from './pages/TripsPage';
import { TripDetailsPage } from './pages/TripDetailsPage';
import { GroupsPage } from './pages/GroupsPage';
import { GroupDetailsPage } from './pages/GroupDetailsPage';
import { SettingsPage } from './pages/SettingsPage';

function AppLayout() {
  const location = useLocation();
  const showBottomNav = ['/home', '/trips', '/groups', '/settings'].includes(location.pathname);

  return (
    <div className="h-screen w-screen overflow-hidden bg-slate-900 flex items-center justify-center">
      {/* Mobile Phone Frame */}
      <div className="relative w-[390px] h-[844px] bg-card rounded-[3rem] shadow-2xl overflow-hidden border-8 border-slate-800">
        {/* Notch */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-40 h-7 bg-slate-900 rounded-b-3xl z-50"></div>

        {/* Screen Content */}
        <div className="h-full w-full overflow-hidden relative">
          <div className="h-full overflow-y-auto scrollbar-hide">
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/signup" element={<SignupPage />} />
              <Route path="/home" element={<HomePage />} />
              <Route path="/notifications" element={<NotificationsPage />} />
              <Route path="/filter" element={<FilterPage />} />
              <Route path="/show-all" element={<ShowAllPage />} />
              <Route path="/filtered-results" element={<FilteredResultsPage />} />
              <Route path="/destination/:id" element={<DestinationDetailsPage />} />
              <Route path="/ai-planner" element={<AIPlannerPage />} />
              <Route path="/customize-itinerary" element={<CustomizeItineraryPage />} />
              <Route path="/trips" element={<TripsPage />} />
              <Route path="/trip/:id" element={<TripDetailsPage />} />
              <Route path="/groups" element={<GroupsPage />} />
              <Route path="/group/:id" element={<GroupDetailsPage />} />
              <Route path="/settings" element={<SettingsPage />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </div>
          {showBottomNav && <BottomNav />}
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        <AppLayout />
      </BrowserRouter>
      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </ThemeProvider>
  );
}