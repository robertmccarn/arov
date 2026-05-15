import { Router } from "express";
import prisma from "../lib/prisma.js";
import { CapacityLevel, DayMode } from "../generated/prisma/enums.js";

const router = Router();

const validCapacityLevels = new Set(Object.values(CapacityLevel));
const validDayModes = new Set(Object.values(DayMode));

router.get("/", async (_req, res) => {
  const items = await prisma.capacityCheckIn.findMany({
    orderBy: { createdAt: "desc" },
  });
  res.json(items);
});

router.post("/", async (req, res) => {
  const { energy, stress, availableTime, mode, notes } = req.body;

  if (!energy || !validCapacityLevels.has(energy)) {
    res.status(400).json({ error: "energy is required and must be one of: LOW, MEDIUM, HIGH, RECOVERY" });
    return;
  }

  if (!stress || !validCapacityLevels.has(stress)) {
    res.status(400).json({ error: "stress is required and must be one of: LOW, MEDIUM, HIGH, RECOVERY" });
    return;
  }

  if (mode !== undefined && !validDayModes.has(mode)) {
    res.status(400).json({ error: "mode must be one of: STABILIZE, BUILD, RESTORE, MIXED" });
    return;
  }

  const data: Record<string, unknown> = {
    energy,
    stress,
  };

  if (availableTime !== undefined) {
    const t = Number(availableTime);
    if (Number.isNaN(t) || t < 0) {
      res.status(400).json({ error: "availableTime must be a non-negative number" });
      return;
    }
    data.availableTime = t;
  }

  if (mode !== undefined) {
    data.mode = mode;
  }

  if (notes !== undefined) {
    if (typeof notes !== "string") {
      res.status(400).json({ error: "notes must be a string" });
      return;
    }
    data.notes = notes;
  }

  const item = await prisma.capacityCheckIn.create({ data: data as any });
  res.status(201).json(item);
});

export default router;
