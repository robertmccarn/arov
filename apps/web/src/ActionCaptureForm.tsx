import { useState } from "react";
import { createActionItem } from "./lib/api.ts";

const CATEGORIES = ["STABILIZE", "BUILD", "RESTORE"] as const;
const LEVELS = ["LOW", "MEDIUM", "HIGH"] as const;

type FormData = {
  title: string;
  description: string;
  category: string;
  supportsStability: boolean;
  effort: string;
  impact: string;
  urgency: string;
};

const emptyForm: FormData = {
  title: "",
  description: "",
  category: "STABILIZE",
  supportsStability: false,
  effort: "MEDIUM",
  impact: "MEDIUM",
  urgency: "MEDIUM",
};

export default function ActionCaptureForm({ onCreated }: { onCreated: () => void }) {
  const [form, setForm] = useState<FormData>(emptyForm);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const set = (field: keyof FormData) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const value = e.target.type === "checkbox" ? (e.target as HTMLInputElement).checked : e.target.value;
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage(null);
    setError(null);

    const trimmed = form.title.trim();
    if (!trimmed) {
      setError("A short title helps keep things clear.");
      return;
    }

    setSubmitting(true);
    try {
      await createActionItem({ ...form, title: trimmed });
      setMessage("Action captured.");
      setForm(emptyForm);
      onCreated();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something unexpected happened.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="capture-form">
      <h2>Capture an action</h2>

      <label>
        Title
        <input name="title" value={form.title} onChange={set("title")} placeholder="What needs doing?" autoFocus />
      </label>

      <label>
        Description
        <textarea name="description" value={form.description} onChange={set("description")} placeholder="Optional details…" rows={3} />
      </label>

      <div className="row">
        <label>
          Category
          <select name="category" value={form.category} onChange={set("category")}>
            {CATEGORIES.map((c) => <option key={c}>{c}</option>)}
          </select>
        </label>

        <label className="checkbox-label">
          <input type="checkbox" name="supportsStability" checked={form.supportsStability} onChange={set("supportsStability")} />
          Supports stability
        </label>
      </div>

      <div className="row triple">
        <label>
          Effort
          <select name="effort" value={form.effort} onChange={set("effort")}>
            {LEVELS.map((l) => <option key={l}>{l}</option>)}
          </select>
        </label>
        <label>
          Impact
          <select name="impact" value={form.impact} onChange={set("impact")}>
            {LEVELS.map((l) => <option key={l}>{l}</option>)}
          </select>
        </label>
        <label>
          Urgency
          <select name="urgency" value={form.urgency} onChange={set("urgency")}>
            {LEVELS.map((l) => <option key={l}>{l}</option>)}
          </select>
        </label>
      </div>

      <button type="submit" disabled={submitting}>
        {submitting ? "Saving…" : "Capture"}
      </button>

      {message && <p className="success">{message}</p>}
      {error && <p className="error-message">{error}</p>}
    </form>
  );
}
