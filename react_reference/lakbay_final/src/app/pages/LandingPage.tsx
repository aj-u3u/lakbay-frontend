import { useNavigate } from 'react-router';
import { Plane } from 'lucide-react';

export function LandingPage() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#20878E] to-[#1a6f75] flex items-center justify-center p-6">
      <div className="text-center">
        <div className="flex justify-center mb-6">
          <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-lg">
            <Plane className="w-12 h-12 text-[#20878E]" />
          </div>
        </div>

        <h1 className="text-4xl text-white mb-3">Lakbay+</h1>
        <p className="text-white/90 mb-12 text-lg">
          Your AI-Powered Travel Companion<br />
          Discover Davao Region
        </p>

        <button
          onClick={() => navigate('/login')}
          className="w-full max-w-sm bg-white text-[#20878E] py-4 rounded-2xl shadow-lg hover:shadow-xl transition-all active:scale-[0.98]"
        >
          Get Started
        </button>
      </div>
    </div>
  );
}
