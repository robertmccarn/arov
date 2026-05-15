import { useEffect, useState } from "react";
import { checkHealth } from "./lib/api.ts";
import "./App.css";

type ConnectionState = "loading" | "connected" | "error";

function App() {
  const [state, setState] = useState<ConnectionState>("loading");

  useEffect(() => {
    checkHealth()
      .then((res) => {
        setState(res.status === "ok" ? "connected" : "error");
      })
      .catch(() => {
        setState("error");
      });
  }, []);

  return (
    <section id="center">
      <div>
        <h1>Arov</h1>
        <p className="status">
          {state === "loading" && "Checking API connection..."}
          {state === "connected" && "API connected"}
          {state === "error" && "API unavailable"}
        </p>
      </div>
    </section>
  );
}

export default App;
