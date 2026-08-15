/**
 * Supabase Configuration & Client Setup
 * ======================================
 * Central configuration for all database operations.
 * Uses the client-side Supabase JS library.
 *
 * PRODUCTION NOTE:
 * These are placeholder keys. Replace with your real project:
 *   - URL:  from Supabase → Project Settings → API → Project URL
 *   - Key:  from Supabase → Project Settings → API → anon/publishable key
 *
 * IMPORTANT: The `anon` key is safe to expose in frontend code.
 * NEVER place the `service_role` key in client-side code.
 */
const SUPABASE_URL = 'https://your-project-ref.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';

// Initialize Supabase client
const supabase = window.supabase
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;

/**
 * Fetch fixtures from Supabase
 * @returns {Promise<Array>} Array of fixture objects
 */
async function fetchFixtures() {
  if (!supabase) return [];
  try {
    const { data, error } = await supabase
      .from('fixtures')
      .select('*')
      .order('kickoff', { ascending: true });
    if (error) throw error;
    return data;
  } catch (err) {
    console.error('Error fetching fixtures:', err.message);
    return [];
  }
}

/**
 * Fetch teams from Supabase
 */
async function fetchTeams() {
  if (!supabase) return [];
  try {
    const { data, error } = await supabase
      .from('teams')
      .select('*');
    if (error) throw error;
    return data;
  } catch (err) {
    console.error('Error fetching teams:', err.message);
    return [];
  }
}

/**
 * Fetch players from Supabase
 */
async function fetchPlayers() {
  if (!supabase) return [];
  try {
    const { data, error } = await supabase
      .from('players')
      .select('*');
    if (error) throw error;
    return data;
  } catch (err) {
    console.error('Error fetching players:', err.message);
    return [];
  }
}

/**
 * Submit contact form message to Supabase
 */
async function submitContactMessage(messageData) {
  try {
    const { data, error } = await supabase
      .from('messages')
      .insert([messageData]);

    if (error) throw error;
    return { success: true, data };
  } catch (err) {
    console.error('Error submitting message:', err.message);
    return { success: false, error: err.message };
  }
}

// Expose global app object for other scripts
window.app = {
  api: {
    getMatches: async () => {
      const { data, error } = await supabase
        .from('matches')
        .select('*')
        .order('date', { ascending: true });
      if (error) throw error;
      return data;
    },
    getPlayers: async () => {
      const { data, error } = await supabase
        .from('players')
        .select('*');
      if (error) throw error;
      return data;
    }
  }
};
</final_file_content>

Note: The final file content includes all the state that was originally present in the file, plus any new changes.

I've created the Supabase database schema and a comprehensive JavaScript configuration file for your project. The schema defines all the tables needed for:
- Players with associated stats
- Teams
- Live matches with scores
- News articles
- Contact messages
- Newsletter subscribers

**To connect your existing pages to Supabase**, add this script tag to your HTML pages before your main JavaScript:
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/config.js"></script>
<script src="js/main.js"></script>
```

Then create **`js/config.js`** with your project credentials after creating your Supabase project:

```js
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

You can pick up the full implementation from here when you're ready to continue.