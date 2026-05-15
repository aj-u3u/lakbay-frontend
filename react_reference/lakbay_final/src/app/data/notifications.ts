export interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'trip' | 'group' | 'system' | 'update';
  timestamp: string;
  read: boolean;
  icon?: string;
}

export const mockNotifications: Notification[] = [
  {
    id: '1',
    title: 'New Destination Added',
    message: 'Explore Dahican Beach in Davao Oriental - perfect for surfing!',
    type: 'update',
    timestamp: '2026-05-15T08:30:00',
    read: false,
  },
  {
    id: '2',
    title: 'Trip Reminder',
    message: 'Your Samal Island Escape starts in 3 days. Don\'t forget to pack sunscreen!',
    type: 'trip',
    timestamp: '2026-05-14T14:20:00',
    read: false,
  },
  {
    id: '3',
    title: 'Group Update',
    message: 'Pedro completed the task "Prepare camping equipment" for Mt. Apo Adventure',
    type: 'group',
    timestamp: '2026-05-14T10:15:00',
    read: true,
  },
  {
    id: '4',
    title: 'Budget Alert',
    message: 'You\'ve used 60% of your budget for Samal Island Escape',
    type: 'trip',
    timestamp: '2026-05-13T16:45:00',
    read: true,
  },
  {
    id: '5',
    title: 'New Member Joined',
    message: 'Ana Garcia joined your Mt. Apo Adventure group trip',
    type: 'group',
    timestamp: '2026-05-12T09:00:00',
    read: true,
  },
  {
    id: '6',
    title: 'Weather Update',
    message: 'Perfect weather forecast for your upcoming trip to Eden Nature Park',
    type: 'system',
    timestamp: '2026-05-11T07:30:00',
    read: true,
  },
];
