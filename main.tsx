import React from 'react';
import ReactDOM from 'react-dom/client';
import Landing from './Landing';

const Workspace = React.lazy(() => import('./WorkspaceEntry'));
const isWorkspace = window.location.pathname === '/app' || window.location.pathname.startsWith('/app/');

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    {isWorkspace ? <React.Suspense fallback={<p role="status">Loading ENote…</p>}><Workspace /></React.Suspense> : <Landing />}
  </React.StrictMode>
);
