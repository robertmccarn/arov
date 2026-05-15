import "dotenv/config";
import express from "express";
import cors from "cors";
import actionItemsRouter from "./routes/actionItems.js";
import capacityCheckInsRouter from "./routes/capacityCheckIns.js";
import reflectionsRouter from "./routes/reflections.js";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "arov-api",
  });
});

app.use("/action-items", actionItemsRouter);
app.use("/capacity-check-ins", capacityCheckInsRouter);
app.use("/reflections", reflectionsRouter);

export default app;
