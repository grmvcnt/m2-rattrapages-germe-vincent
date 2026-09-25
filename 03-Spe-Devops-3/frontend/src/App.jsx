import { useEffect, useState } from 'react';

export default function App() {
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/message')
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Reponse ${response.status}`);
        }
        return response.json();
      })
      .then((data) => setMessage(data.message))
      .catch((err) => setError(err.message));
  }, []);

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-white rounded-lg shadow-sm border border-slate-200 p-6 space-y-4">
        <div>
          <h1 className="text-xl font-semibold text-slate-900">Vincent GERME</h1>
          <p className="text-sm text-slate-500">IIM</p>
        </div>

        <p className="text-sm text-slate-600">Rattrapage - Spe Devops 3</p>

        <div className="border-t border-slate-200 pt-4">
          <p className="text-sm text-blue-500">Communication backend :</p>
          {error ? (
            <p className="text-sm text-red-600">Erreur Backend : {error}</p>
          ) : (
            <p className="text-sm text-slate-800">{message || 'Chargement...'}</p>
          )}
        </div>
      </div>
    </div>
  );
}
