@role(platform)

# Agent Communication Protocols
# Generated from: cues/agent-communication-protocols.cues.md
# REQ-NNN: Structured inter-agent messaging

kind MessageSchema = {
  schema_id: String,
  message_type: String,
  required_fields: List[String],
  optional_fields: List[String]
}

kind CommunicationChannel = {
  channel_id: String,
  participants: List[String],
  message_schemas: List[MessageSchema],
  lifecycle_status: String
}

kind MessageRouting = {
  routing_id: String,
  source_agent: String,
  target_capabilities: List[String],
  routing_strategy: String
}

maplet createMessageSchema ∷ String → MessageSchema
maplet establishChannel ∷ CommunicationChannel → String
maplet routeMessage ∷ MessageRouting → List[String]

contract StructuredCommunication ⊨ requires:
  - All messages conform to standardized schemas
  - Channel lifecycle properly managed
  - Message routing based on capability matching
  ⊨ ensures:
  - Reliable inter-agent communication
  - Efficient message delivery
  - Communication protocol consistency

plan establishCommunicationInfrastructure § steps:
  1. defineMessageSchemas ▸ createStandardizedFormats
  2. implementChannelManagement ▸ enableCommunicationLifecycle
  3. buildMessageRouting ▸ enableCapabilityBasedDelivery
  4. validateCommunicationProtocols ▸ ensureReliability
  5. optimizeMessageDelivery ▸ maximizeEfficiency

artifact CommunicationInfrastructure = {
  format: "Communication protocol implementation",
  required_components: ["message_schemas", "channel_manager", "routing_engine"],
  validation: "Inter-agent communication operational"
}