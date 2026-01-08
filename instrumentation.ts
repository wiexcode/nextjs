import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
import { ConsoleSpanExporter } from '@opentelemetry/sdk-trace-node';


const traceExporter = new OTLPTraceExporter({
  // Example: send traces to a local collector
  // url: 'http://localhost:4318/v1/traces'
  // url: 'http://10.190.13.52:4318/v1/traces'
   url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://10.190.13.52:4318/v1/traces',
});


const sdk = new NodeSDK({
  resource: resourceFromAttributes({
    [SemanticResourceAttributes.SERVICE_NAME]: 'nextjs-demo-service',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
    // optional
    // [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: 'development',
  }),  
  traceExporter,
  // traceExporter: process.env.NODE_ENV === 'development' ? consoleExporter : otlpExporter,
  instrumentations: [getNodeAutoInstrumentations()],
});


sdk.start();