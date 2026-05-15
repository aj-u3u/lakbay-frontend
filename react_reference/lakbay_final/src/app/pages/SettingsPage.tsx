import { useState } from 'react';
import { useNavigate } from 'react-router';
import { useTheme } from '../components/ThemeContext';
import {
  ChevronRight,
  Bell,
  MapPin,
  Palette,
  Lock,
  HelpCircle,
  LogOut,
  Sun,
  Moon,
  Monitor,
} from 'lucide-react';

export function SettingsPage() {
  const navigate = useNavigate();
  const { theme, setTheme } = useTheme();
  const [showAppearanceModal, setShowAppearanceModal] = useState(false);

  return (
    <div className="pb-20 bg-background min-h-screen relative">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <h2 className="mb-6">Settings</h2>

          <div className="bg-card rounded-2xl p-5 shadow-sm">
            <div className="flex items-center gap-4 mb-4">
              <div className="w-20 h-20 bg-gradient-to-br from-primary to-secondary rounded-full flex items-center justify-center text-white text-2xl">
                JD
              </div>
              <div className="flex-1">
                <h3>Juan Dela Cruz</h3>
                <p className="text-sm text-muted-foreground">juan.delacruz@email.com</p>
              </div>
            </div>
            <button className="w-full py-2 border-2 border-border rounded-xl text-sm hover:bg-accent transition-colors">
              Edit Profile
            </button>
          </div>
        </div>
      </div>

      <div className="px-6 space-y-6">
        <section>
          <h4 className="mb-3 text-muted-foreground">Preferences</h4>
          <div className="bg-card rounded-2xl shadow-sm overflow-hidden divide-y divide-border">
            <button className="w-full p-4 flex items-center gap-4 hover:bg-accent transition-colors">
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <Bell className="w-5 h-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p>Notifications</p>
                <p className="text-sm text-muted-foreground">Push, email, SMS</p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </button>

            <button className="w-full p-4 flex items-center gap-4 hover:bg-accent transition-colors">
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <MapPin className="w-5 h-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p>Default Region</p>
                <p className="text-sm text-muted-foreground">Davao Region</p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </button>

            <button
              onClick={() => setShowAppearanceModal(true)}
              className="w-full p-4 flex items-center gap-4 hover:bg-accent transition-colors"
            >
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <Palette className="w-5 h-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p>Appearance</p>
                <p className="text-sm text-muted-foreground capitalize">
                  {theme === 'system' ? 'System default' : theme}
                </p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>
        </section>

        <section>
          <h4 className="mb-3 text-muted-foreground">Account & Privacy</h4>
          <div className="bg-card rounded-2xl shadow-sm overflow-hidden divide-y divide-border">
            <button className="w-full p-4 flex items-center gap-4 hover:bg-accent transition-colors">
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <Lock className="w-5 h-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p>Privacy & Security</p>
                <p className="text-sm text-muted-foreground">Password, data, permissions</p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>
        </section>

        <section>
          <h4 className="mb-3 text-muted-foreground">Support</h4>
          <div className="bg-card rounded-2xl shadow-sm overflow-hidden divide-y divide-border">
            <button className="w-full p-4 flex items-center gap-4 hover:bg-accent transition-colors">
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <HelpCircle className="w-5 h-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p>Help Center</p>
                <p className="text-sm text-muted-foreground">FAQs and support</p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>
        </section>

        <button
          onClick={() => navigate('/')}
          className="w-full bg-destructive/10 text-destructive py-4 rounded-2xl flex items-center justify-center gap-2 hover:bg-destructive/20 transition-colors"
        >
          <LogOut className="w-5 h-5" />
          Logout
        </button>

        <div className="text-center text-muted-foreground text-sm pb-6">
          <p>Lakbay+ v1.0.0</p>
          <p>Made with ❤️ for Davao Region</p>
        </div>
      </div>

      {showAppearanceModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end justify-center"
          onClick={() => setShowAppearanceModal(false)}
        >
          <div
            className="bg-card w-full rounded-t-3xl p-6 max-h-[70vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-6">Choose Appearance</h3>

            <div className="space-y-3 pb-4">
              <button
                onClick={() => {
                  setTheme('light');
                  setShowAppearanceModal(false);
                }}
                className={`w-full p-4 rounded-2xl flex items-center gap-4 transition-colors ${
                  theme === 'light'
                    ? 'bg-primary/10 border-2 border-primary'
                    : 'bg-accent hover:bg-accent/70'
                }`}
              >
                <div className="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                  <Sun className="w-6 h-6 text-yellow-600" />
                </div>
                <div className="flex-1 text-left">
                  <p>Light Mode</p>
                  <p className="text-sm text-muted-foreground">Bright and clear</p>
                </div>
              </button>

              <button
                onClick={() => {
                  setTheme('dark');
                  setShowAppearanceModal(false);
                }}
                className={`w-full p-4 rounded-2xl flex items-center gap-4 transition-colors ${
                  theme === 'dark'
                    ? 'bg-primary/10 border-2 border-primary'
                    : 'bg-accent hover:bg-accent/70'
                }`}
              >
                <div className="w-10 h-10 bg-slate-800 rounded-full flex items-center justify-center">
                  <Moon className="w-6 h-6 text-blue-300" />
                </div>
                <div className="flex-1 text-left">
                  <p>Dark Mode</p>
                  <p className="text-sm text-muted-foreground">Easy on the eyes</p>
                </div>
              </button>

              <button
                onClick={() => {
                  setTheme('system');
                  setShowAppearanceModal(false);
                }}
                className={`w-full p-4 rounded-2xl flex items-center gap-4 transition-colors ${
                  theme === 'system'
                    ? 'bg-primary/10 border-2 border-primary'
                    : 'bg-accent hover:bg-accent/70'
                }`}
              >
                <div className="w-10 h-10 bg-slate-300 rounded-full flex items-center justify-center">
                  <Monitor className="w-6 h-6 text-slate-700" />
                </div>
                <div className="flex-1 text-left">
                  <p>System Default</p>
                  <p className="text-sm text-muted-foreground">Follows device settings</p>
                </div>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
