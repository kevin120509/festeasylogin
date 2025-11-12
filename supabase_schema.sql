-- Create the 'profiles' table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  rol TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for 'profiles' table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy to allow authenticated users to insert their own profile
CREATE POLICY "Allow authenticated users to insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy to allow authenticated users to view their own profile" ON profiles
CREATE POLICY "Allow authenticated users to view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Policy to allow authenticated users to update their own profile
CREATE POLICY "Allow authenticated users to update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create the 'clientes' table
CREATE TABLE clientes (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for 'clientes' table
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- Policy to allow authenticated users to insert their own client data
CREATE POLICY "Allow authenticated users to insert their own client data" ON clientes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy to allow authenticated users to view their own client data
CREATE POLICY "Allow authenticated users to view their own client data" ON clientes
  FOR SELECT USING (auth.uid() = user_id);

-- Policy to allow authenticated users to update their own client data
CREATE POLICY "Allow authenticated users to update their own client data" ON clientes
  FOR UPDATE USING (auth.uid() = user_id);

-- Create the 'proveedores' table
CREATE TABLE proveedores (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for 'proveedores' table
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;

-- Policy to allow authenticated users to insert their own provider data
CREATE POLICY "Allow authenticated users to insert their own provider data" ON proveedores
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy to allow authenticated users to view their own provider data
CREATE POLICY "Allow authenticated users to view their own provider data" ON proveedores
  FOR SELECT USING (auth.uid() = user_id);

-- Policy to allow authenticated users to update their own provider data
CREATE POLICY "Allow authenticated users to update their own provider data" ON proveedores
  FOR UPDATE USING (auth.uid() = user_id);