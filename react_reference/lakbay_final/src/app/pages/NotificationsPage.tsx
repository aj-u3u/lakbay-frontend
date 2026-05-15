import { useNavigate } from 'react-router';
import { ArrowLeft, Bell, MapPin, Users, Info } from 'lucide-react';
import { mockNotifications } from '../data/notifications';

export function NotificationsPage() {
  const navigate = useNavigate();

  const unreadCount = mockNotifications.filter(n => !n.read).length;

  const getIcon = (type: string) => {
    switch (type) {
      case 'trip':
        return MapPin;
      case 'group':
        return Users;
      case 'system':
      case 'update':
        return Info;
      default:
        return Bell;
    }
  };

  const getTimeAgo = (timestamp: string) => {
    const now = new Date();
    const time = new Date(timestamp);
    const diffInHours = Math.floor((now.getTime() - time.getTime()) / (1000 * 60 * 60));

    if (diffInHours < 1) return 'Just now';
    if (diffInHours < 24) return `${diffInHours}h ago`;
    const diffInDays = Math.floor(diffInHours / 24);
    if (diffInDays === 1) return 'Yesterday';
    return `${diffInDays}d ago`;
  };

  return (
    <div className="min-h-screen bg-background pb-6">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <div className="flex items-center gap-4 mb-6">
            <button
              onClick={() => navigate('/home')}
              className="p-2 hover:bg-accent rounded-full transition-colors"
            >
              <ArrowLeft className="w-6 h-6" />
            </button>
            <div className="flex-1">
              <h2>Notifications</h2>
              {unreadCount > 0 && (
                <p className="text-sm text-muted-foreground">{unreadCount} unread</p>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="px-6 space-y-3">
        {mockNotifications.map((notification) => {
          const Icon = getIcon(notification.type);
          return (
            <div
              key={notification.id}
              className={`bg-card rounded-2xl p-4 shadow-sm transition-colors ${
                !notification.read ? 'border-2 border-primary/20' : ''
              }`}
            >
              <div className="flex gap-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                  notification.type === 'trip' ? 'bg-primary/10' :
                  notification.type === 'group' ? 'bg-secondary/10' :
                  'bg-accent'
                }`}>
                  <Icon className={`w-5 h-5 ${
                    notification.type === 'trip' ? 'text-primary' :
                    notification.type === 'group' ? 'text-secondary' :
                    'text-muted-foreground'
                  }`} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <h4 className="text-sm">{notification.title}</h4>
                    {!notification.read && (
                      <span className="w-2 h-2 bg-primary rounded-full flex-shrink-0 mt-1"></span>
                    )}
                  </div>
                  <p className="text-sm text-muted-foreground mb-2">{notification.message}</p>
                  <p className="text-xs text-muted-foreground">{getTimeAgo(notification.timestamp)}</p>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
