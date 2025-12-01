export interface HeartRateRecord {
  id: number;
  timestamp: number;
  heartRate: number;
  date: string;
  time: string;
  sensorType: string;
}

export interface StepCountRecord {
  id: number;
  timestamp: number;
  stepCount: number;
  date: string;
  time: string;
  sensorType: string;
}