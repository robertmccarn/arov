import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import actionItemsRouter from "./routes/actionItems.js";
import capacityCheckInsRouter from "./routes/capacityCheckIns.js";

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;

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

app.listen(port, () => {
  console.log(`Arov API listening on port ${port}`);
});
