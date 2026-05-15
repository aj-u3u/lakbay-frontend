import { useState } from 'react';
import { useParams, useNavigate } from 'react-router';
import {
  ArrowLeft,
  MapPin,
  Calendar,
  Users,
  UserPlus,
  Send,
  Wallet,
  CheckSquare,
  ChevronDown,
  ChevronUp,
  X,
  Plus,
  Navigation,
  Bus,
  StickyNote,
  Camera,
  Edit2,
  Check,
  Trash2,
} from 'lucide-react';
import { mockGroupTrips } from '../data/groups';

export function GroupDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<
    'itinerary' | 'route' | 'transport'
  >('itinerary');
  const [expandedDay, setExpandedDay] = useState<number | null>(1);
  const [showBudgetModal, setShowBudgetModal] = useState(false);
  const [showAddMemberModal, setShowAddMemberModal] = useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [showTaskModal, setShowTaskModal] = useState(false);

  const [isEditingBudget, setIsEditingBudget] = useState(false);
  const [editedTotalBudget, setEditedTotalBudget] = useState('');
  const [editingMemberId, setEditingMemberId] = useState<string | null>(null);
  const [editedContribution, setEditedContribution] = useState('');

  // Notes CRUD
  const [isAddingNote, setIsAddingNote] = useState(false);
  const [newNote, setNewNote] = useState('');
  const [editingNoteIndex, setEditingNoteIndex] = useState<number | null>(null);
  const [editedNote, setEditedNote] = useState('');

  // Photos CRUD
  const [isAddingPhoto, setIsAddingPhoto] = useState(false);
  const [newPhotoUrl, setNewPhotoUrl] = useState('');

  const group = mockGroupTrips.find((g) => g.id === id);

  if (!group) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <p>Group trip not found</p>
      </div>
    );
  }

  const leader = group.members.find((m) => m.isLeader);
  const budgetProgress = (group.budget.spent / group.budget.total) * 100;
  const completedTasks = group.tasks.filter((t) => t.completed).length;

  const handleSaveBudget = () => {
    console.log('Saving total budget:', editedTotalBudget);
    setIsEditingBudget(false);
  };

  const handleSaveMemberContribution = (memberId: string) => {
    console.log('Saving contribution for member:', memberId, editedContribution);
    setEditingMemberId(null);
    setEditedContribution('');
  };

  const handleRemoveMember = (memberId: string) => {
    console.log('Removing member:', memberId);
  };

  // Notes handlers
  const handleAddNote = () => {
    if (newNote.trim()) {
      console.log('Adding note:', newNote);
      setNewNote('');
      setIsAddingNote(false);
    }
  };

  const handleEditNote = (index: number) => {
    if (editedNote.trim()) {
      console.log('Editing note at index:', index, editedNote);
      setEditingNoteIndex(null);
      setEditedNote('');
    }
  };

  const handleDeleteNote = (index: number) => {
    console.log('Deleting note at index:', index);
  };

  // Photos handlers
  const handleAddPhoto = () => {
    if (newPhotoUrl.trim()) {
      console.log('Adding photo:', newPhotoUrl);
      setNewPhotoUrl('');
      setIsAddingPhoto(false);
    }
  };

  const handleDeletePhoto = (index: number) => {
    console.log('Deleting photo at index:', index);
  };

  return (
    <div className="min-h-screen bg-background pb-20">
      <div className="relative h-56">
        <img src={group.image} alt={group.name} className="w-full h-full object-cover" />
        <button
          onClick={() => navigate('/groups')}
          className="absolute top-6 left-4 p-2 bg-white/95 backdrop-blur-sm rounded-full shadow-lg"
        >
          <ArrowLeft className="w-6 h-6" />
        </button>
      </div>

      <div className="p-6">
        <h2 className="mb-2">{group.name}</h2>
        <div className="flex items-center gap-2 text-muted-foreground mb-4">
          <MapPin className="w-4 h-4" />
          <span className="text-sm">{group.destination}</span>
        </div>
        <div className="flex items-center gap-2 text-muted-foreground mb-6">
          <Calendar className="w-4 h-4" />
          <span className="text-sm">
            {new Date(group.startDate).toLocaleDateString()} -{' '}
            {new Date(group.endDate).toLocaleDateString()}
          </span>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <h4 className="mb-2">Trip Summary</h4>
          <p className="text-muted-foreground text-sm">{group.summary}</p>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <Users className="w-5 h-5 text-secondary" />
              Members ({group.members.length})
            </h4>
            <div className="flex gap-2">
              <button
                onClick={() => setShowAddMemberModal(true)}
                className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
              >
                <UserPlus className="w-4 h-4" />
              </button>
              <button
                onClick={() => setShowInviteModal(true)}
                className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
              >
                <Send className="w-4 h-4" />
              </button>
              <button
                onClick={() => setShowBudgetModal(true)}
                className="px-3 py-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors text-sm flex items-center gap-1"
              >
                <Wallet className="w-4 h-4" />
                Budget
              </button>
            </div>
          </div>

          <div className="mb-3">
            <p className="text-sm text-muted-foreground mb-2">Leader</p>
            <div className="flex items-center gap-3">
              <img
                src={leader?.avatar}
                alt={leader?.name}
                className="w-10 h-10 rounded-full"
              />
              <div>
                <p className="text-sm">{leader?.name}</p>
                <p className="text-xs text-muted-foreground">Trip organizer</p>
              </div>
            </div>
          </div>

          <div>
            <p className="text-sm text-muted-foreground mb-2">Team</p>
            <div className="grid grid-cols-2 gap-3">
              {group.members
                .filter((m) => !m.isLeader)
                .map((member) => (
                  <div key={member.id} className="flex items-center gap-2">
                    <img
                      src={member.avatar}
                      alt={member.name}
                      className="w-8 h-8 rounded-full"
                    />
                    <p className="text-sm truncate">{member.name}</p>
                  </div>
                ))}
            </div>
          </div>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <CheckSquare className="w-5 h-5 text-secondary" />
              Tasks ({completedTasks}/{group.tasks.length})
            </h4>
            <button
              onClick={() => setShowTaskModal(true)}
              className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          <div className="space-y-2">
            {group.tasks.map((task) => (
              <div
                key={task.id}
                className="flex items-center gap-3 p-3 bg-accent/30 rounded-xl"
              >
                <input
                  type="checkbox"
                  checked={task.completed}
                  onChange={() => {}}
                  className="w-5 h-5 rounded border-2 border-secondary text-secondary focus:ring-secondary"
                />
                <div className="flex-1">
                  <p className={`text-sm ${task.completed ? 'line-through text-muted-foreground' : ''}`}>
                    {task.title}
                  </p>
                  <p className="text-xs text-muted-foreground">{task.assignedTo}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <StickyNote className="w-5 h-5 text-secondary" />
              Travel Notes
            </h4>
            <button
              onClick={() => setIsAddingNote(true)}
              className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {isAddingNote && (
            <div className="mb-4 p-3 bg-accent/30 rounded-xl">
              <textarea
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                placeholder="Enter your travel note..."
                rows={2}
                className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-secondary resize-none mb-2"
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => {
                    setIsAddingNote(false);
                    setNewNote('');
                  }}
                  className="px-3 py-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddNote}
                  className="px-3 py-1 bg-secondary text-secondary-foreground rounded-lg hover:shadow-lg transition-all text-sm"
                >
                  Add Note
                </button>
              </div>
            </div>
          )}

          <ul className="space-y-2">
            {group.notes.map((note, idx) => (
              <li key={idx}>
                {editingNoteIndex === idx ? (
                  <div className="p-3 bg-accent/30 rounded-xl">
                    <textarea
                      value={editedNote}
                      onChange={(e) => setEditedNote(e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-secondary resize-none mb-2"
                    />
                    <div className="flex gap-2 justify-end">
                      <button
                        onClick={() => {
                          setEditingNoteIndex(null);
                          setEditedNote('');
                        }}
                        className="p-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors"
                      >
                        <X className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleEditNote(idx)}
                        className="p-1 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="flex gap-3 p-3 bg-accent/30 rounded-xl group hover:bg-accent/50 transition-colors">
                    <span className="text-secondary">•</span>
                    <span className="text-sm flex-1">{note}</span>
                    <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => {
                          setEditingNoteIndex(idx);
                          setEditedNote(note);
                        }}
                        className="p-1 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteNote(idx)}
                        className="p-1 bg-destructive/10 text-destructive rounded-lg hover:bg-destructive/20 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                )}
              </li>
            ))}
          </ul>

          {group.notes.length === 0 && !isAddingNote && (
            <div className="text-center py-8">
              <StickyNote className="w-12 h-12 mx-auto mb-3 text-muted-foreground" />
              <p className="text-muted-foreground text-sm">No travel notes yet</p>
            </div>
          )}
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <Camera className="w-5 h-5 text-secondary" />
              Shared Memories
            </h4>
            <button
              onClick={() => setIsAddingPhoto(true)}
              className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {isAddingPhoto && (
            <div className="mb-4 p-3 bg-accent/30 rounded-xl">
              <input
                type="text"
                value={newPhotoUrl}
                onChange={(e) => setNewPhotoUrl(e.target.value)}
                placeholder="Enter photo URL (e.g., https://images.unsplash.com/...)"
                className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-secondary mb-2"
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => {
                    setIsAddingPhoto(false);
                    setNewPhotoUrl('');
                  }}
                  className="px-3 py-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddPhoto}
                  className="px-3 py-1 bg-secondary text-secondary-foreground rounded-lg hover:shadow-lg transition-all text-sm"
                >
                  Add Photo
                </button>
              </div>
            </div>
          )}

          {group.photos.length === 0 && !isAddingPhoto ? (
            <div className="text-center py-8">
              <Camera className="w-12 h-12 mx-auto mb-3 text-muted-foreground" />
              <p className="text-muted-foreground text-sm">
                No photos yet. Start capturing memories!
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-3">
              {group.photos.map((photo, idx) => (
                <div key={idx} className="aspect-square bg-muted rounded-xl overflow-hidden relative group">
                  <img src={photo} alt={`Memory ${idx + 1}`} className="w-full h-full object-cover" />
                  <button
                    onClick={() => handleDeletePhoto(idx)}
                    className="absolute top-2 right-2 p-2 bg-destructive/90 text-destructive-foreground rounded-lg opacity-0 group-hover:opacity-100 transition-opacity hover:bg-destructive"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="flex gap-2 overflow-x-auto pb-2 mb-6 scrollbar-hide">
          <button
            onClick={() => setActiveTab('itinerary')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'itinerary'
                ? 'bg-secondary text-secondary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Itinerary
          </button>
          <button
            onClick={() => setActiveTab('route')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'route'
                ? 'bg-secondary text-secondary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Route
          </button>
          <button
            onClick={() => setActiveTab('transport')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'transport'
                ? 'bg-secondary text-secondary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Transport
          </button>
        </div>

        {activeTab === 'itinerary' && (
          <div className="space-y-4">
            {group.itinerary.map((day) => (
              <div key={day.day} className="bg-card rounded-2xl shadow-sm overflow-hidden">
                <button
                  onClick={() => setExpandedDay(expandedDay === day.day ? null : day.day)}
                  className="w-full p-5 flex justify-between items-center hover:bg-accent/50 transition-colors"
                >
                  <div className="text-left">
                    <h4>Day {day.day}</h4>
                    <p className="text-sm text-muted-foreground">{day.title}</p>
                  </div>
                  {expandedDay === day.day ? (
                    <ChevronUp className="w-5 h-5 text-muted-foreground" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-muted-foreground" />
                  )}
                </button>

                {expandedDay === day.day && (
                  <div className="px-5 pb-5 space-y-4">
                    {day.activities.map((activity, idx) => (
                      <div key={idx} className="flex gap-3">
                        <div className="text-sm text-secondary whitespace-nowrap pt-1">
                          {activity.time}
                        </div>
                        <div className="flex-1">
                          <p className="text-sm mb-1">{activity.activity}</p>
                          <div className="flex items-center gap-1 text-muted-foreground">
                            <MapPin className="w-3 h-3" />
                            <span className="text-xs">{activity.location}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {activeTab === 'route' && (
          <div className="bg-card rounded-2xl p-5 shadow-sm">
            <h4 className="mb-4 flex items-center gap-2">
              <Navigation className="w-5 h-5 text-secondary" />
              Route Optimization
            </h4>
            <div className="aspect-video bg-muted rounded-xl flex items-center justify-center mb-4">
              <div className="text-center">
                <MapPin className="w-12 h-12 mx-auto mb-2 text-muted-foreground" />
                <p className="text-muted-foreground text-sm">Interactive Map of Mt. Apo</p>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'transport' && (
          <div className="space-y-3">
            {group.transport.map((item, idx) => (
              <div key={idx} className="bg-card rounded-2xl p-5 shadow-sm">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 bg-secondary/10 rounded-full flex items-center justify-center">
                    <Bus className="w-5 h-5 text-secondary" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-sm">{item.mode}</h4>
                    <p className="text-xs text-muted-foreground">
                      {item.from} → {item.to}
                    </p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-xs text-muted-foreground">Fare</p>
                    <p className="text-sm">{item.fare}</p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">Duration</p>
                    <p className="text-sm">{item.duration}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {showBudgetModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
          onClick={() => setShowBudgetModal(false)}
        >
          <div
            className="bg-card w-full max-w-lg rounded-t-3xl sm:rounded-3xl max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="sticky top-0 bg-card z-10 flex justify-between items-center p-4 border-b border-border">
              <h3>Shared Budget</h3>
              <button
                onClick={() => setShowBudgetModal(false)}
                className="p-2 hover:bg-accent rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-6">
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-muted-foreground">Total Budget</span>
                  {isEditingBudget ? (
                    <div className="flex items-center gap-2">
                      <input
                        type="number"
                        value={editedTotalBudget}
                        onChange={(e) => setEditedTotalBudget(e.target.value)}
                        placeholder={group.budget.total.toString()}
                        className="w-32 px-3 py-1 bg-input-background rounded-lg text-right focus:outline-none focus:ring-2 focus:ring-secondary"
                      />
                      <button
                        onClick={handleSaveBudget}
                        className="p-1 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => {
                          setIsEditingBudget(false);
                          setEditedTotalBudget('');
                        }}
                        className="p-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors"
                      >
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <span className="text-xl">₱{group.budget.total.toLocaleString()}</span>
                      <button
                        onClick={() => {
                          setIsEditingBudget(true);
                          setEditedTotalBudget(group.budget.total.toString());
                        }}
                        className="p-1 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                </div>
                <div className="flex justify-between mb-2">
                  <span className="text-muted-foreground">Per Person</span>
                  <span>₱{group.budget.perPerson.toLocaleString()}</span>
                </div>
                <div className="flex justify-between mb-3">
                  <span className="text-muted-foreground">Spent</span>
                  <span className="text-secondary">₱{group.budget.spent.toLocaleString()}</span>
                </div>
                <div className="w-full bg-muted rounded-full h-3">
                  <div
                    className="bg-secondary rounded-full h-3 transition-all"
                    style={{ width: `${budgetProgress}%` }}
                  />
                </div>
              </div>

              <div>
                <h4 className="mb-3">Member Contributions</h4>
                <div className="space-y-3">
                  {group.members.map((member) => (
                    <div key={member.id} className="bg-accent/30 rounded-xl p-3">
                      <div className="flex items-center gap-3">
                        <img
                          src={member.avatar}
                          alt={member.name}
                          className="w-10 h-10 rounded-full"
                        />
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-1">
                            <p className="text-sm">{member.name}</p>
                            {member.isLeader && (
                              <span className="px-2 py-0.5 bg-secondary/20 text-secondary text-xs rounded-full">
                                Leader
                              </span>
                            )}
                          </div>

                          {editingMemberId === member.id ? (
                            <div className="flex items-center gap-2">
                              <input
                                type="number"
                                value={editedContribution}
                                onChange={(e) => setEditedContribution(e.target.value)}
                                placeholder={member.contribution.toString()}
                                className="w-28 px-2 py-1 bg-input-background rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-secondary"
                              />
                              <button
                                onClick={() => handleSaveMemberContribution(member.id)}
                                className="p-1 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                              >
                                <Check className="w-3 h-3" />
                              </button>
                              <button
                                onClick={() => {
                                  setEditingMemberId(null);
                                  setEditedContribution('');
                                }}
                                className="p-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors"
                              >
                                <X className="w-3 h-3" />
                              </button>
                            </div>
                          ) : (
                            <div className="flex items-center gap-4 text-xs text-muted-foreground">
                              <span>Pledged: ₱{member.contribution.toLocaleString()}</span>
                              <span>Spent: ₱{member.spent.toLocaleString()}</span>
                            </div>
                          )}
                        </div>

                        <div className="flex gap-1">
                          {editingMemberId !== member.id && (
                            <>
                              <button
                                onClick={() => {
                                  setEditingMemberId(member.id);
                                  setEditedContribution(member.contribution.toString());
                                }}
                                className="p-2 bg-secondary/10 text-secondary rounded-lg hover:bg-secondary/20 transition-colors"
                              >
                                <Edit2 className="w-4 h-4" />
                              </button>
                              {!member.isLeader && (
                                <button
                                  onClick={() => handleRemoveMember(member.id)}
                                  className="p-2 bg-destructive/10 text-destructive rounded-lg hover:bg-destructive/20 transition-colors"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              )}
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <h4 className="mb-3">Expense Breakdown</h4>
                <div className="space-y-3">
                  {group.budget.categories.map((category, idx) => (
                    <div key={idx}>
                      <div className="flex justify-between mb-2">
                        <span className="text-sm">{category.name}</span>
                        <span className="text-sm">₱{category.amount.toLocaleString()}</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div
                          className="rounded-full h-2 transition-all"
                          style={{
                            width: `${(category.amount / group.budget.total) * 100}%`,
                            backgroundColor: category.color,
                          }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {showAddMemberModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
          onClick={() => setShowAddMemberModal(false)}
        >
          <div
            className="bg-card w-full max-w-md rounded-t-3xl sm:rounded-3xl p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex justify-between items-center mb-6">
              <h3>Add Member</h3>
              <button
                onClick={() => setShowAddMemberModal(false)}
                className="p-2 hover:bg-accent rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <input
                type="text"
                placeholder="Search by name or email"
                className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-secondary"
              />
              <button className="w-full bg-secondary text-secondary-foreground py-3 rounded-xl">
                Add Member
              </button>
            </div>
          </div>
        </div>
      )}

      {showInviteModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
          onClick={() => setShowInviteModal(false)}
        >
          <div
            className="bg-card w-full max-w-md rounded-t-3xl sm:rounded-3xl p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex justify-between items-center mb-6">
              <h3>Invite Members</h3>
              <button
                onClick={() => setShowInviteModal(false)}
                className="p-2 hover:bg-accent rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <textarea
                placeholder="Enter email addresses (comma separated)"
                rows={4}
                className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-secondary resize-none"
              />
              <button className="w-full bg-secondary text-secondary-foreground py-3 rounded-xl flex items-center justify-center gap-2">
                <Send className="w-5 h-5" />
                Send Invites
              </button>
            </div>
          </div>
        </div>
      )}

      {showTaskModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
          onClick={() => setShowTaskModal(false)}
        >
          <div
            className="bg-card w-full max-w-md rounded-t-3xl sm:rounded-3xl p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex justify-between items-center mb-6">
              <h3>Add Task</h3>
              <button
                onClick={() => setShowTaskModal(false)}
                className="p-2 hover:bg-accent rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <input
                type="text"
                placeholder="Task title"
                className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-secondary"
              />
              <select className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-secondary">
                <option>Assign to...</option>
                {group.members.map((member) => (
                  <option key={member.id}>{member.name}</option>
                ))}
              </select>
              <button className="w-full bg-secondary text-secondary-foreground py-3 rounded-xl">
                Create Task
              </button>
            </div>
          </div>
        </div>
      )}

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
