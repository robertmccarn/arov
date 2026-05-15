const BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:4000";

export interface HealthResponse {
  status: string;
  service: string;
}

export interface ActionItemData {
  title: string;
  description?: string;
  category: string;
  supportsStability?: boolean;
  effort: string;
  impact: string;
  urgency: string;
}

export interface ActionItem extends ActionItemData {
  id: string;
  status: string;
  createdAt: string;
  updatedAt: string;
}

export async function checkHealth(): Promise<HealthResponse> {
  const res = await fetch(`${BASE_URL}/health`);
  if (!res.ok) {
    throw new Error(`Health check failed: ${res.status}`);
  }
  return res.json();
}

export async function createActionItem(data: ActionItemData): Promise<ActionItem> {
  const res = await fetch(`${BASE_URL}/action-items`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || `Request failed: ${res.status}`);
  }
  return res.json();
}

export async function listActionItems(): Promise<ActionItem[]> {
  const res = await fetch(`${BASE_URL}/action-items`);
  if (!res.ok) {
    throw new Error(`Failed to list action items: ${res.status}`);
  }
  return res.json();
}
