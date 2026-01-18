-- Add conversation_id column to messages table
ALTER TABLE messages ADD COLUMN IF NOT EXISTS conversation_id text;

-- Update existing messages with a generated conversation_id
-- Logic: LEAST(sender_id, receiver_id) || '_' || GREATEST(sender_id, receiver_id)
UPDATE messages
SET conversation_id = CASE
    WHEN sender_id < receiver_id THEN sender_id::text || '_' || receiver_id::text
    ELSE receiver_id::text || '_' || sender_id::text
END
WHERE conversation_id IS NULL;

-- Create function to automatically set conversation_id on insert
-- This ensures backward compatibility for clients that don't send conversation_id yet
CREATE OR REPLACE FUNCTION public.set_conversation_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Always calculate conversation_id to ensure consistency
    NEW.conversation_id := CASE
        WHEN NEW.sender_id < NEW.receiver_id THEN NEW.sender_id::text || '_' || NEW.receiver_id::text
        ELSE NEW.receiver_id::text || '_' || NEW.sender_id::text
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Trigger
DROP TRIGGER IF EXISTS trigger_set_conversation_id ON messages;
CREATE TRIGGER trigger_set_conversation_id
BEFORE INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION public.set_conversation_id();

-- Make conversation_id NOT NULL after backfilling and adding trigger
ALTER TABLE messages ALTER COLUMN conversation_id SET NOT NULL;

-- Create an index on conversation_id for fast filtering
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
