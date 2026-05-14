import { Router } from "express";
import prisma from "../lib/prisma.js";
import { ActionStatus } from "../generated/prisma/enums.js";

const router = Router();

router.get("/", async (_req, res) => {
  const items = await prisma.actionItem.findMany({
    orderBy: { createdAt: "desc" },
  });
  res.json(items);
});

router.post("/", async (req, res) => {
  const { title } = req.body;
  if (!title || typeof title !== "string") {
    res.status(400).json({ error: "title is required" });
    return;
  }

  const allowedFields = [
    "description",
    "category",
    "supportsStability",
    "effort",
    "impact",
    "urgency",
    "status",
    "dueDate",
  ];
  const data: Record<string, unknown> = { title };

  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      data[field] = req.body[field];
    }
  }

  if (data.dueDate) {
    data.dueDate = new Date(data.dueDate as string);
  }

  const item = await prisma.actionItem.create({ data: data as any });
  res.status(201).json(item);
});

router.get("/:id", async (req, res) => {
  const item = await prisma.actionItem.findUnique({
    where: { id: req.params.id },
  });
  if (!item) {
    res.status(404).json({ error: "ActionItem not found" });
    return;
  }
  res.json(item);
});

router.patch("/:id", async (req, res) => {
  const existing = await prisma.actionItem.findUnique({
    where: { id: req.params.id },
  });
  if (!existing) {
    res.status(404).json({ error: "ActionItem not found" });
    return;
  }

  const allowedFields = [
    "title",
    "description",
    "category",
    "supportsStability",
    "effort",
    "impact",
    "urgency",
    "status",
    "dueDate",
    "completedAt",
  ];
  const data: Record<string, unknown> = {};

  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      data[field] = req.body[field];
    }
  }

  if (data.dueDate) {
    data.dueDate = new Date(data.dueDate as string);
  }

  if (data.status === ActionStatus.DONE && !existing.completedAt && !data.completedAt) {
    data.completedAt = new Date();
  }

  if (
    data.status &&
    data.status !== ActionStatus.DONE &&
    existing.status === ActionStatus.DONE &&
    !data.completedAt
  ) {
    data.completedAt = null;
  }

  const item = await prisma.actionItem.update({
    where: { id: req.params.id },
    data: data as any,
  });
  res.json(item);
});

router.delete("/:id", async (req, res) => {
  const existing = await prisma.actionItem.findUnique({
    where: { id: req.params.id },
  });
  if (!existing) {
    res.status(404).json({ error: "ActionItem not found" });
    return;
  }

  const item = await prisma.actionItem.update({
    where: { id: req.params.id },
    data: { status: "ARCHIVED" as any },
  });
  res.json(item);
});

export default router;
