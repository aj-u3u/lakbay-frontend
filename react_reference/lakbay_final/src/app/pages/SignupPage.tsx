import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Eye, EyeOff } from 'lucide-react';

export function SignupPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSignup = (e: React.FormEvent) => {
    e.preventDefault();
    navigate('/home');
  };

  return (
    <div className="min-h-screen bg-background p-6 flex flex-col">
      <button
        onClick={() => navigate('/login')}
        className="self-start mb-8 p-2 hover:bg-accent rounded-full transition-colors"
      >
        <ArrowLeft className="w-6 h-6" />
      </button>

      <div className="flex-1 flex flex-col justify-center max-w-md mx-auto w-full">
        <h2 className="text-3xl mb-2">Create Account</h2>
        <p className="text-muted-foreground mb-8">Join Lakbay+ and start exploring</p>

        <form onSubmit={handleSignup} className="space-y-4">
          <div>
            <label className="block mb-2 text-sm">Full Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Juan Dela Cruz"
              className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-primary"
              required
            />
          </div>

          <div>
            <label className="block mb-2 text-sm">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="your.email@example.com"
              className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-primary"
              required
            />
          </div>

          <div>
            <label className="block mb-2 text-sm">Password</label>
            <div className="relative">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Create a strong password"
                className="w-full px-4 py-3 bg-input-background rounded-xl focus:outline-none focus:ring-2 focus:ring-primary pr-12"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground"
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="w-full bg-primary text-primary-foreground py-4 rounded-xl shadow-lg hover:shadow-xl transition-all active:scale-[0.98] mt-6"
          >
            Create Account
          </button>
        </form>

        <div className="mt-6 text-center">
          <span className="text-muted-foreground">Already have an account? </span>
          <button
            onClick={() => navigate('/login')}
            className="text-primary hover:underline"
          >
            Sign In
          </button>
        </div>
      </div>
    </div>
  );
}
