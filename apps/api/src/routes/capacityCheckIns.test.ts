import { describe, it, expect } from "vitest";
import request from "supertest";
import app from "../app.js";

describe("GET /capacity-check-ins", () => {
  it("returns an array", async () => {
    const res = await request(app).get("/capacity-check-ins");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});

describe("POST /capacity-check-ins", () => {
  it("creates a check-in with valid energy and stress", async () => {
    const res = await request(app)
      .post("/capacity-check-ins")
      .send({ energy: "MEDIUM", stress: "LOW" })
      .set("Content-Type", "application/json");
    expect(res.status).toBe(201);
    expect(res.body.energy).toBe("MEDIUM");
    expect(res.body.stress).toBe("LOW");
    expect(res.body.id).toBeDefined();
  });

  it("returns 400 when stress is missing", async () => {
    const res = await request(app)
      .post("/capacity-check-ins")
      .send({ energy: "MEDIUM" })
      .set("Content-Type", "application/json");
    expect(res.status).toBe(400);
    expect(res.body.error).toContain("stress");
  });

  it("returns 400 when energy is invalid", async () => {
    const res = await request(app)
      .post("/capacity-check-ins")
      .send({ energy: "INVALID", stress: "LOW" })
      .set("Content-Type", "application/json");
    expect(res.status).toBe(400);
    expect(res.body.error).toContain("energy");
  });

  it("returns 400 when mode is invalid", async () => {
    const res = await request(app)
      .post("/capacity-check-ins")
      .send({ energy: "MEDIUM", stress: "LOW", mode: "INVALID" })
      .set("Content-Type", "application/json");
    expect(res.status).toBe(400);
    expect(res.body.error).toContain("mode");
  });
});
