import { Home, MapPin, Users, Settings } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router';

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();

  const isActive = (path: string) => location.pathname === path;

  const navItems = [
    { path: '/home', icon: Home, label: 'Home' },
    { path: '/trips', icon: MapPin, label: 'Trip' },
    { path: '/groups', icon: Users, label: 'Groups' },
    { path: '/settings', icon: Settings, label: 'Settings' },
  ];

  return (
    <nav className="absolute bottom-0 left-0 right-0 bg-card border-t border-border shadow-lg z-40">
      <div className="flex justify-around items-center h-20 px-2">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActive(item.path);

          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`flex flex-col items-center justify-center gap-1 px-4 py-2 rounded-2xl transition-all ${
                active ? 'text-primary' : 'text-muted-foreground'
              }`}
            >
              <div
                className={`p-2 rounded-xl transition-colors ${
                  active ? 'bg-primary/10' : 'hover:bg-accent'
                }`}
              >
                <Icon className="w-6 h-6" strokeWidth={active ? 2.5 : 2} />
              </div>
              <span className="text-xs">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
