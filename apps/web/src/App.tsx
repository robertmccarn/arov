import { useEffect, useState } from "react";
import { checkHealth, listActionItems, type ActionItem } from "./lib/api.ts";
import ActionCaptureForm from "./ActionCaptureForm.tsx";
import "./App.css";

type ConnectionState = "loading" | "connected" | "error";

function App() {
  const [connection, setConnection] = useState<ConnectionState>("loading");
  const [items, setItems] = useState<ActionItem[]>([]);

  const check = () => {
    checkHealth()
      .then((res) => setConnection(res.status === "ok" ? "connected" : "error"))
      .catch(() => setConnection("error"));
  };

  const loadItems = () => {
    listActionItems()
      .then(setItems)
      .catch(() => {});
  };

  useEffect(() => { check(); loadItems(); }, []);

  return (
    <>
      <section id="center">
        <div>
          <h1>Arov</h1>
          <p className="status">
            {connection === "loading" && "Checking API connection..."}
            {connection === "connected" && "API connected"}
            {connection === "error" && "API unavailable"}
          </p>
        </div>

        {connection === "connected" && (
          <ActionCaptureForm onCreated={loadItems} />
        )}
      </section>

      <section id="items">
        <h2>Recent actions</h2>
        {items.length === 0 && <p className="empty">No actions captured yet.</p>}
        <ul>
          {items.map((item) => (
            <li key={item.id}>
              <strong>{item.title}</strong>
              <span className="meta">{item.category} · {item.status}</span>
            </li>
          ))}
        </ul>
      </section>
    </>
  );
}

export default App;
