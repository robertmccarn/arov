import { Router } from "express";
import prisma from "../lib/prisma.js";
import { EffortLevel } from "../generated/prisma/enums.js";

const router = Router();

const validEffortLevels = new Set(Object.values(EffortLevel));

router.get("/", async (_req, res) => {
  const items = await prisma.reflection.findMany({
    orderBy: { createdAt: "desc" },
  });
  res.json(items);
});

router.post("/", async (req, res) => {
  const { actionItemId, stressReduced, momentumCreated, actualEffort, notes } = req.body;

  if (actionItemId !== undefined) {
    if (typeof actionItemId !== "string") {
      res.status(400).json({ error: "actionItemId must be a string" });
      return;
    }
    const actionItem = await prisma.actionItem.findUnique({
      where: { id: actionItemId },
    });
    if (!actionItem) {
      res.status(404).json({ error: "ActionItem not found" });
      return;
    }
  }

  if (actualEffort !== undefined && !validEffortLevels.has(actualEffort)) {
    res.status(400).json({ error: "actualEffort must be one of: LOW, MEDIUM, HIGH" });
    return;
  }

  if (notes !== undefined && typeof notes !== "string") {
    res.status(400).json({ error: "notes must be a string" });
    return;
  }

  const data: Record<string, unknown> = {};

  if (actionItemId !== undefined) data.actionItemId = actionItemId;
  if (stressReduced !== undefined) data.stressReduced = Boolean(stressReduced);
  if (momentumCreated !== undefined) data.momentumCreated = Boolean(momentumCreated);
  if (actualEffort !== undefined) data.actualEffort = actualEffort;
  if (notes !== undefined) data.notes = notes;

  const item = await prisma.reflection.create({ data: data as any });
  res.status(201).json(item);
});

export default router;
