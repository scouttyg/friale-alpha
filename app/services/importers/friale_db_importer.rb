module Importers
  class FrialeDbImporter
    attr_reader :postgres_database_name, :postgres_user, :postgres_password, :docs_folder

    OLD_DB_MAPPINGS = {
      "Bay Area" => {
        city: "Bay Area",
        region: "California",
        country: "United States"
      },
      "Bay Area & China" => {
        multiple: [
          {
            city: "Bay Area",
            region: "California",
            country: "United States"
          },
          {
            city: nil,
            region: nil,
            country: "China"
          }
        ]
      },
      "Austin" => {
        city: "Austin",
        region: "Texas",
        country: "United States"
      },
      "Austin, TX" => {
        city: "Austin",
        region: "Texas",
        country: "United States"
      },
      "Boston" => {
        city: "Boston",
        region: "Massachusetts",
        country: "United States"
      },
      "Brazil" => {
        city: nil,
        region: nil,
        country: "Brazil"
      },
      "Cambridge, UK" => {
        city: "Cambridge",
        region: "England",
        country: "United Kingdom"
      },
      "Canada" => {
        city: nil,
        region: nil,
        country: "Canada"
      },
      "Chicago" => {
        city: "Chicago",
        region: "Illinois",
        country: "United States"
      },
      "Crossville, Tennessee" => {
        city: "Crossville",
        region: "Tennessee",
        country: "United States"
      },
      "Dallas" => {
        city: "Dallas",
        region: "Texas",
        country: "United States"
      },
      "Distributed (US)" => {
        city: nil,
        region: nil,
        country: "United States"
      },
      "Dubai" => {
        city: "Dubai",
        region: "Dubai",
        country: "United Arab Emirates"
      },
      "Dublin & Bay Area" => {
        multiple: [
          {
            city: "Dublin",
            region: "Dublin",
            country: "Ireland"
          },
          {
            city: "Bay Area",
            region: "California",
            country: "United States"
          }
        ]
      },
      "France" => {
        city: nil,
        region: nil,
        country: "France"
      },
      "Ghana" => {
        city: nil,
        region: nil,
        country: "Ghana"
      },
      "Houston" => {
        city: "Houston",
        region: "Texas",
        country: "United States"
      },
      "India" => {
        city: nil,
        region: nil,
        country: "India"
      },
      "Israel" => {
        city: nil,
        region: nil,
        country: "Israel"
      },
      "London" => {
        city: "London",
        region: "England",
        country: "United Kingdom"
      },
      "Los Angeles" => {
        city: "Los Angeles",
        region: "California",
        country: "United States"
      },
      "Mexico" => {
        city: nil,
        region: nil,
        country: "Mexico"
      },
      "Mexico & Bay Area" => {
        multiple: [
          {
            city: nil,
            region: nil,
            country: "Mexico"
          },
          {
            city: "Bay Area",
            region: "California",
            country: "United States"
          }
        ]
      },
      "Moscow" => {
        city: "Moscow",
        region: nil,
        country: "Russia"
      },
      "Nashville" => {
        city: "Nashville",
        region: "Tennessee",
        country: "United States"
      },
      "New York" => {
        city: nil,
        region: "New York",
        country: "United States"
      },
      "Newfoundland" => {
        city: nil,
        region: "Newfoundland and Labrador",
        country: "Canada"
      },
      "Nigeria" => {
        city: nil,
        region: nil,
        country: "Nigeria"
      },
      "NYC" => {
        city: "New York City",
        region: "New York",
        country: "United States"
      },
      "Oxford" => {
        city: "Oxford",
        region: "England",
        country: "United Kingdom"
      },
      "Palo Alto, CA" => {
        city: "Palo Alto",
        region: "California",
        country: "United States"
      },
      "Phoenix, Arizona" => {
        city: "Phoenix",
        region: "Arizona",
        country: "United States"
      },
      "San Diego" => {
        city: "San Diego",
        region: "California",
        country: "United States"
      },
      "San Francisco" => {
        city: "San Francisco",
        region: "California",
        country: "United States"
      },
      "San Francisco, CA" => {
        city: "San Francisco",
        region: "California",
        country: "United States"
      },
      "Seattle" => {
        city: "Seattle",
        region: "Washington",
        country: "United States"
      },
      "Singapore" => {
        city: nil,
        region: nil,
        country: "Singapore"
      },
      "St. Louis" => {
        city: "St. Louis",
        region: "Missouri",
        country: "United States"
      },
      "US" => {
        city: nil,
        region: nil,
        country: "United States"
      }
    }

    def initialize
      @postgres_database_name = "friale"
      @docs_folder = ENV.fetch("DEFAULT_FRIALE_DOC_IMPORT_FOLDER")
      @postgres_user = ENV.fetch("POSTGRES_USER")
      @postgres_password = ENV.fetch("POSTGRES_PASSWORD")
    end

    def generate_all!
      puts "Starting import process..."

      @stats = {}

      generate_users!
      generate_locations!
      generate_firm_accounts!
      generate_funds!
      generate_companies!
      generate_company_notes!
      generate_investor_accounts!
      # Skip fund managers - no longer exists
      generate_positions!
      generate_assets!
      generate_marks!
      generate_bank_accounts!
      generate_fund_investor_investments!
      generate_fund_distributions!
      generate_fund_investor_transactions!
      generate_documents!

      puts "\n✅ Import process completed!"
      print_import_summary
    end

    # Load documents from PostgreSQL database and file system
    def generate_documents!
      puts "Importing documents..."

      # First, try to import any documents from the PostgreSQL database
      already_imported_files = import_database_documents!

      import_filesystem_documents!(already_imported_files)

      puts "Documents import completed!"
    end

    private

    def postgres_connection
      @postgres_connection ||= PG.connect(
        host: "localhost",
        dbname: postgres_database_name,
        user: postgres_user,
        password: postgres_password
      )
    rescue PG::Error => e
      Rails.logger.error "Failed to connect to PostgreSQL database: #{e.message}"
      raise "Could not connect to PostgreSQL database '#{postgres_database_name}'. Make sure it's running and accessible."
    end

    # Load core_users and pull into users table in rails app
    def generate_users!
      puts "Importing users..."

      query = "SELECT id, email, first_name, last_name, username, is_active, date_joined FROM core_user WHERE is_active = true"
      result = postgres_connection.exec(query)

      result.each do |row|
        user = User.where(email: row["email"]).first_or_initialize
        was_new_record = user.new_record?

        user.first_name = row["first_name"]
        user.last_name = row["last_name"]
        user.password = "temporary_password_123" if was_new_record # Set temporary password for new users
        user.confirmed_at = Time.current if was_new_record # Auto-confirm imported users

        was_changed = user.changed?
        user.save!

        track_record(:users, user, was_changed)
        log_record_action(user, was_changed, "user: #{user.email}")
      end

      puts "Users import completed!"
    end

    # Load locations based on company location strings
    def generate_locations!
      puts "Importing locations..."

      query = "SELECT DISTINCT location FROM core_company WHERE location IS NOT NULL AND location != ''"
      result = postgres_connection.exec(query)

      result.each do |row|
        location_name = row["location"].strip
        next if location_name.blank?

        # Check if we have a predefined mapping for this location
        if OLD_DB_MAPPINGS[location_name]
          mapping = OLD_DB_MAPPINGS[location_name]
          city = mapping[:city]
          region = mapping[:region]
          country = mapping[:country]
        else
          # Fallback: Parse location string (assuming format like "City, State" or "City, Country")
          parts = location_name.split(",").map(&:strip)
          city = parts[0]
          region = parts[1] if parts.length > 1
          country = nil
          puts "  ⚠️  No mapping found for: #{location_name}, using fallback parsing"
        end

        location = Location.where(city: city, region: region, country: country).first_or_initialize
        was_new_record = location.new_record?

        location.slug = location_name.parameterize

        was_changed = location.changed?
        location.save!

        track_record(:locations, location, was_changed)
        log_record_action(location, was_changed, "location: #{location_name} -> #{city || 'nil'}, #{region || 'nil'}, #{country || 'nil'}")
      end

      puts "Locations import completed!"
    end

    # Load core_firms and pull into firm_accounts table in rails app
    def generate_firm_accounts!
      puts "Importing firm accounts..."

      query = "SELECT id, name, created_at FROM core_firm ORDER BY id"
      result = postgres_connection.exec(query)

      result.each do |row|
        firm_account = FirmAccount.where(name: row["name"]).first_or_initialize
        was_new_record = firm_account.new_record?

        # Always sync created_at from original Django data
        firm_account.created_at = row["created_at"]

        was_changed = firm_account.changed?
        firm_account.save!

        track_record(:firm_accounts, firm_account, was_changed)
        log_record_action(firm_account, was_changed, "firm account: #{firm_account.name}")
      end

      puts "Firm accounts import completed!"
    end

    # Load core_funds and pull into funds table in rails app
    def generate_funds!
      puts "Importing funds..."

      query = <<~SQL
        SELECT f.id, f.name, f.slug, f.created_at, firm.name as firm_name
        FROM core_fund f
        JOIN core_firm firm ON f.firm_id = firm.id
        WHERE f.visible = true
        ORDER BY f.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        firm_account = FirmAccount.find_by(name: row["firm_name"])
        next unless firm_account

        fund = Fund.where(name: row["name"], firm_account: firm_account).first_or_initialize
        was_new_record = fund.new_record?

        fund.slug = row["slug"]
        # Always sync created_at from original Django data
        fund.created_at = row["created_at"]

        was_changed = fund.changed?
        fund.save!

        track_record(:funds, fund, was_changed)
        log_record_action(fund, was_changed, "fund: #{fund.name} (#{firm_account.name})")
      end

      puts "Funds import completed!"
    end

    # Load core_companies and pull into companies table in rails app
    def generate_companies!
      puts "Importing companies..."

      query = <<~SQL
        SELECT c.id, c.name, c.website, c.description, c.location, firm.name as firm_name
        FROM core_company c
        JOIN core_firm firm ON c.firm_id = firm.id
        ORDER BY c.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        firm_account = FirmAccount.find_by(name: row["firm_name"])
        next unless firm_account

        company = Company.where(name: row["name"], firm_account: firm_account).first_or_initialize
        was_new_record = company.new_record?

        company.website = row["website"]
        company.description = row["description"]

        was_changed = company.changed?
        company.save!

        # Handle location associations through the join table
        location_string = row["location"]&.strip
        if location_string.present?
          locations_to_associate = []

          # Check if we have a mapping for this location string
          if OLD_DB_MAPPINGS[location_string]
            mapping = OLD_DB_MAPPINGS[location_string]

            if mapping[:multiple]
              # Handle multiple locations (e.g., "Bay Area & China")
              mapping[:multiple].each do |location_data|
                location = find_or_create_location(location_data[:city], location_data[:region], location_data[:country])
                locations_to_associate << location if location
              end
            else
              # Handle single location
              location = find_or_create_location(mapping[:city], mapping[:region], mapping[:country])
              locations_to_associate << location if location
            end
          else
            # Fallback: Parse location string
            parts = location_string.split(",").map(&:strip)
            city = parts[0]
            region = parts[1] if parts.length > 1
            location = find_or_create_location(city, region, nil)
            locations_to_associate << location if location
            puts "  ⚠️  No mapping found for: #{location_string}, using fallback parsing"
          end

          # Associate locations with company through join table
          locations_to_associate.each do |location|
            company_location = CompanyLocation.find_or_create_by(company: company, location: location)
            track_record(:company_locations, company_location) if company_location.previously_new_record?
          end

          log_record_action(company, was_changed, "company: #{company.name} with #{locations_to_associate.size} location(s)")
        else
          log_record_action(company, was_changed, "company: #{company.name} (no location)")
        end

        track_record(:companies, company, was_changed)
      end

      puts "Companies import completed!"
    end

    # Load core_companynote and pull into company_notes table in rails app
    def generate_company_notes!
      puts "Importing company notes..."

      query = <<~SQL
        SELECT cn.id, cn.note, cn.url, cn.active, cn.investor_visible,
               cn.performance, cn.stage, c.name as company_name
        FROM core_companynote cn
        JOIN core_company c ON cn.company_id = c.id
        ORDER BY cn.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        company = Company.find_by(name: row["company_name"])
        next unless company

        company_note = CompanyNote.where(company: company, note: row["note"]).first_or_initialize
        was_new_record = company_note.new_record?

        company_note.url = row["url"]
        company_note.active = row["active"] == "t"
        company_note.investor_visible = row["investor_visible"] == "t"

        # Map performance string to enum
        case row["performance"]&.downcase
        when "below"
          company_note.performance = :BELOW
        when "average"
          company_note.performance = :AVERAGE
        when "above"
          company_note.performance = :ABOVE
        when "high"
          company_note.performance = :HIGH
        end

        # Map stage string to enum
        case row["stage"]&.downcase
        when "seed"
          company_note.stage = :SEED
        when "series_a", "series a"
          company_note.stage = :SERIES_A
        when "series_b", "series b"
          company_note.stage = :SERIES_B
        when "series_c", "series c"
          company_note.stage = :SERIES_C
        when "series_d", "series d"
          company_note.stage = :SERIES_D
        when "series_e", "series e"
          company_note.stage = :SERIES_E
        when "series_f", "series f"
          company_note.stage = :SERIES_F
        when "acquired", "aquired"
          company_note.stage = :AQUIRED
        end

        was_changed = company_note.changed?
        company_note.save!

        track_record(:company_notes, company_note, was_changed)
        log_record_action(company_note, was_changed, "company note for: #{company.name}")
      end

      puts "Company notes import completed!"
    end

    # Load core_investors and pull into investor_accounts table in rails app
    def generate_investor_accounts!
      puts "Importing investor accounts..."

      query = <<~SQL
        SELECT i.id, i.name, ip.user_id, u.email
        FROM core_investor i
        LEFT JOIN core_investorprofile ip ON i.id = ip.investor_id
        LEFT JOIN core_user u ON ip.user_id = u.id
        ORDER BY i.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        user = User.find_by(email: row["email"]) if row["email"]
        next unless user # Skip investors without associated users

        investor_account = InvestorAccount.where(name: row["name"]).first_or_initialize
        was_new_record = investor_account.new_record?

        was_changed = investor_account.changed?
        investor_account.save!

        # Create account membership for the user
        if was_new_record
          AccountMember.find_or_create_by(
            source: investor_account,
            user: user,
            access_level: :owner
          )
        end

        track_record(:investor_accounts, investor_account, was_changed)
        log_record_action(investor_account, was_changed, "investor account: #{row['name']} (#{user.email})")
      end

      puts "Investor accounts import completed!"
    end

    # Load core_positions
    def generate_positions!
      puts "Importing positions..."

      query = <<~SQL
        SELECT p.id, p.invested_capital, p.returned_capital, p.open_date, p.close_date,
               c.name as company_name, f.name as fund_name
        FROM core_position p
        JOIN core_company c ON p.company_id = c.id
        JOIN core_fund f ON p.fund_id = f.id
        ORDER BY p.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        company = Company.find_by(name: row["company_name"])
        fund = Fund.find_by(name: row["fund_name"])

        next unless company && fund

        position = Position.where(company: company, fund: fund).first_or_initialize
        was_new_record = position.new_record?

        # Convert to cents for monetized fields
        position.invested_capital = Money.new((row["invested_capital"].to_f * 100).to_i) if row["invested_capital"]
        position.returned_capital = Money.new((row["returned_capital"].to_f * 100).to_i) if row["returned_capital"]
        position.open_date = row["open_date"]
        position.close_date = row["close_date"]

        was_changed = position.changed?
        position.save!

        track_record(:positions, position, was_changed)
        log_record_action(position, was_changed, "position: #{company.name} in #{fund.name}")
      end

      puts "Positions import completed!"
    end

    # Load core_assets
    def generate_assets!
      puts "Importing assets..."

      # First pass: Create all assets without converted_asset relationships
      query = <<~SQL
        SELECT a.id, a.origination, a.asset_type, a.quantity, a.current, a.cap, a.discount,
               a.converted_from_id, a.created_at, pc.name as position_company_name, pf.name as position_fund_name
        FROM core_asset a
        JOIN core_position p ON a.position_id = p.id
        JOIN core_company pc ON p.company_id = pc.id
        JOIN core_fund pf ON p.fund_id = pf.id
        ORDER BY a.id
      SQL

      result = postgres_connection.exec(query)
      postgres_to_rails_asset_map = {}

      result.each do |row|
        # Find position by company and fund (same logic as position import)
        position_company = Company.find_by(name: row["position_company_name"])
        position_fund = Fund.find_by(name: row["position_fund_name"])

        next unless position_company && position_fund

        position = Position.find_by(company: position_company, fund: position_fund)
        next unless position

        quantity = row["quantity"].to_d if row["quantity"]
        postgres_asset_id = row["id"].to_i
        converted_from_postgres_id = row["converted_from_id"]&.to_i

        # We need to include more identifying information to ensure uniqueness
        # Since we can't resolve converted_asset in first pass, we'll use other attributes
        asset = Asset.where(
          position: position,
          quantity: quantity
        ).find do |existing_asset|
          # Check if this asset matches all the attributes we're about to set
          matches_origination = case row["origination"]&.downcase
          when "conversion"
            existing_asset.origination == "CONVERSION"
          when "sale"
            existing_asset.origination == "SALE"
          when "purchase"
            existing_asset.origination == "PURCHASE"
          else
            existing_asset.origination.nil?
          end

          matches_asset_type = case row["asset_type"]&.downcase
          when "safe"
            existing_asset.asset_type == "SAFE"
          when "equity", "common", "preferred"
            existing_asset.asset_type == "EQUITY"
          when "cash"
            existing_asset.asset_type == "CASH"
          when "note", "convertible note"
            existing_asset.asset_type == "NOTE"
          when "escrow"
            existing_asset.asset_type == "ESCROW"
          else
            existing_asset.asset_type.nil?
          end

          matches_current = existing_asset.current == (row["current"] == "t")

          matches_origination && matches_asset_type && matches_current
        end

        # If no matching asset found, create a new one
        asset ||= Asset.new(
          position: position,
          quantity: quantity
        )

        was_new_record = asset.new_record?

        # Always sync created_at from original Django data (handle date field)
        if row["created_at"]
          asset.created_at = Date.parse(row["created_at"]).beginning_of_day
        end

        asset.current = row["current"] == "t"
        # Convert to Money objects for monetized fields
        asset.cap = Money.new((row["cap"].to_f * 100).to_i) if row["cap"]
        asset.discount = row["discount"].to_i if row["discount"] # This seems to be stored as percentage

        # Map origination string to enum
        case row["origination"]&.downcase
        when "conversion"
          asset.origination = :CONVERSION
        when "sale"
          asset.origination = :SALE
        when "purchase"
          asset.origination = :PURCHASE
        end

        # Map asset_type string to enum
        case row["asset_type"]&.downcase
        when "safe"
          asset.asset_type = :SAFE
        when "equity", "common", "preferred"
          asset.asset_type = :EQUITY
        when "cash"
          asset.asset_type = :CASH
        when "note", "convertible note"
          asset.asset_type = :NOTE
        when "escrow"
          asset.asset_type = :ESCROW
        end

        was_changed = asset.changed?
        asset.save!

        track_record(:assets, asset, was_changed)
        # Store mapping of PostgreSQL ID to Rails asset for second pass
        postgres_to_rails_asset_map[postgres_asset_id] = asset

        log_record_action(asset, was_changed, "asset for: #{position.company.name}")
      end

      # Second pass: Update converted_asset relationships
      puts "Setting up asset conversion relationships..."
      result.each do |row|
        next unless row["converted_from_id"]

        postgres_asset_id = row["id"].to_i
        converted_from_postgres_id = row["converted_from_id"].to_i

        rails_asset = postgres_to_rails_asset_map[postgres_asset_id]
        converted_from_asset = postgres_to_rails_asset_map[converted_from_postgres_id]

        if rails_asset && converted_from_asset
          rails_asset.update!(converted_asset: converted_from_asset)
          puts "  Linked asset conversion: #{rails_asset.id} converted from #{converted_from_asset.id}"
        end
      end

      puts "Assets import completed!"
    end

    # Load core_marks
    def generate_marks!
      puts "Importing marks..."

      # First, build a mapping of PostgreSQL asset IDs to Rails Asset objects
      # This assumes generate_assets! has already been run
      postgres_to_rails_asset_map = {}

      asset_query = <<~SQL
        SELECT a.id as postgres_asset_id, pc.name as position_company_name, pf.name as position_fund_name,
               a.quantity, a.asset_type, a.origination, a.current
        FROM core_asset a
        JOIN core_position p ON a.position_id = p.id
        JOIN core_company pc ON p.company_id = pc.id
        JOIN core_fund pf ON p.fund_id = pf.id
        ORDER BY a.id
      SQL

      asset_result = postgres_connection.exec(asset_query)
      asset_result.each do |asset_row|
        # Find position by company and fund (same logic as asset import)
        position_company = Company.find_by(name: asset_row["position_company_name"])
        position_fund = Fund.find_by(name: asset_row["position_fund_name"])

        next unless position_company && position_fund

        position = Position.find_by(company: position_company, fund: position_fund)

        if position
          quantity = asset_row["quantity"].to_d if asset_row["quantity"]

          # Map PostgreSQL asset_type and origination to Rails enums
          rails_asset_type = case asset_row["asset_type"]&.downcase
          when "safe"
            :SAFE
          when "equity", "common", "preferred"
            :EQUITY
          when "cash"
            :CASH
          when "note", "convertible note"
            :NOTE
          when "escrow"
            :ESCROW
          end

          rails_origination = case asset_row["origination"]&.downcase
          when "conversion"
            :CONVERSION
          when "sale"
            :SALE
          when "purchase"
            :PURCHASE
          end

          current = asset_row["current"] == "t"

          # Find asset by position, quantity, asset_type, origination, and current status
          asset = Asset.find_by(
            position: position,
            quantity: quantity,
            asset_type: rails_asset_type,
            origination: rails_origination,
            current: current
          )

          if asset
            postgres_to_rails_asset_map[asset_row["postgres_asset_id"].to_i] = asset
          else
            puts "  ⚠️  Could not find Rails asset for PostgreSQL asset ID #{asset_row['postgres_asset_id']} (#{position.company.name}, qty: #{quantity}, type: #{rails_asset_type})"
          end
        end
      end

      # Now import marks with proper asset associations
      query = <<~SQL
        SELECT m.id, m.date, m.price, m.source, m.note, m.asset_id
        FROM core_mark m
        ORDER BY m.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        postgres_asset_id = row["asset_id"].to_i
        asset = postgres_to_rails_asset_map[postgres_asset_id]

        mark_date = row["date"]
        price = row["price"].to_f if row["price"]
        notes = row["note"]

        # Map source string to enum first
        rails_source = case row["source"]&.downcase
        when "purchase_price", "purchase price"
          :PURCHASE_PRICE
        when "latest_buyer", "latest buyer"
          :LATEST_BUYER
        when "other"
          :OTHER
        else
          nil
        end

        # Use mark_date, price_cents, notes, asset, and source as unique identifiers to prevent duplicates
        price_money = Money.new((price * 100).to_i) if price
        mark = Mark.where(
          mark_date: mark_date,
          price_cents: price_money&.cents,
          notes: notes,
          asset: asset,
          source: rails_source
        ).first_or_initialize

        was_new_record = mark.new_record?
        mark.price = price_money if price_money
        mark.source = rails_source

        was_changed = mark.changed?
        mark.save!

        track_record(:marks, mark, was_changed)

        if asset
          log_record_action(mark, was_changed, "mark: #{mark.mark_date} for #{asset.company.name} asset")
        else
          log_record_action(mark, was_changed, "⚠️  mark: #{mark.mark_date} (no matching asset found for PostgreSQL asset ID #{postgres_asset_id})")
        end
      end

      puts "Marks import completed!"
    end

    # Load core_bankaccounts
    def generate_bank_accounts!
      puts "Importing bank accounts..."

      query = <<~SQL
        SELECT ba.id, ba.routing_number, ba.account_number, ba.bank_name, ba.owner_name,
               ba.address, ba.notes, i.name as investor_name, u.email
        FROM core_bankaccount ba
        JOIN core_investor i ON ba.investor_id = i.id
        LEFT JOIN core_investorprofile ip ON i.id = ip.investor_id
        LEFT JOIN core_user u ON ip.user_id = u.id
        ORDER BY ba.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        user = User.find_by(email: row["email"]) if row["email"]
        next unless user

        # Find the investor account by name (since we can't rely on direct user->investor relationship anymore)
        investor_account = InvestorAccount.find_by(name: row["investor_name"])
        next unless investor_account

        # Query jsonb metadata column for routing_number and account_number
        bank_account = BankAccount.where(
          account: investor_account
        ).where(
          "metadata->>'routing_number' = ? AND metadata->>'account_number' = ?",
          row["routing_number"],
          row["account_number"]
        ).first_or_initialize

        was_new_record = bank_account.new_record?

        bank_account.bank_name = row["bank_name"]
        bank_account.owner_name = row["owner_name"]
        bank_account.address = row["address"]
        bank_account.notes = row["notes"]
        bank_account.last_four = row["account_number"]&.last(4) if row["account_number"]
        bank_account.routing_number = row["routing_number"].gsub(/[^0-9]/, "")
        bank_account.account_number = row["account_number"]

        # Mark as migrated to skip certain validations
        bank_account.migrated = true

        # Generate a fake Stripe payment method ID for now (required field)
        if was_new_record
          bank_account.stripe_payment_method_id = "pm_IMPORTED#{SecureRandom.alphanumeric(14)}"
        end

        was_changed = bank_account.changed?
        bank_account.save!

        track_record(:bank_accounts, bank_account, was_changed)
        log_record_action(bank_account, was_changed, "bank account: #{bank_account.bank_name} for #{row['investor_name']}")
      end

      puts "Bank accounts import completed!"
    end

    # Load core_investorfundinvestment and pull into fund_investor_investments table
    def generate_fund_investor_investments!
      puts "Importing fund investor investments..."

      query = <<~SQL
        SELECT ifi.id, ifi.capital_commitment, ifi.capital_funded,
               f.name as fund_name, i.name as investor_name
        FROM core_investorfundinvestment ifi
        JOIN core_fund f ON ifi.fund_id = f.id
        JOIN core_investor i ON ifi.investor_id = i.id
        ORDER BY ifi.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        fund = Fund.find_by(name: row["fund_name"])
        investor_account = InvestorAccount.find_by(name: row["investor_name"])

        next unless fund && investor_account

        investment = FundInvestorInvestment.where(fund: fund, investor_account: investor_account).first_or_initialize
        was_new_record = investment.new_record?

        # Convert to Money objects
        investment.capital_commitment = Money.new((row["capital_commitment"].to_f * 100).to_i) if row["capital_commitment"]
        investment.capital_funded = Money.new((row["capital_funded"].to_f * 100).to_i) if row["capital_funded"]

        was_changed = investment.changed?
        investment.save!

        track_record(:fund_investor_investments, investment, was_changed)
        log_record_action(investment, was_changed, "fund investment: #{investor_account.name} in #{fund.name}")
      end

      puts "Fund investor investments import completed!"
    end

    # Load core_funddistribution and pull into fund_distributions table
    def generate_fund_distributions!
      puts "Importing fund distributions..."

      query = <<~SQL
        SELECT fd.id, fd.name, fd.amount, fd.date, fd.notes,
               f.name as fund_name, c.name as position_company_name, pf.name as position_fund_name
        FROM core_funddistribution fd
        JOIN core_fund f ON fd.fund_id = f.id
        LEFT JOIN core_position p ON fd.position_id = p.id
        LEFT JOIN core_company c ON p.company_id = c.id
        LEFT JOIN core_fund pf ON p.fund_id = pf.id
        ORDER BY fd.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        fund = Fund.find_by(name: row["fund_name"])
        next unless fund

        # Find position if specified
        position = nil
        if row["position_company_name"] && row["position_fund_name"]
          position_company = Company.find_by(name: row["position_company_name"])
          position_fund = Fund.find_by(name: row["position_fund_name"])
          position = Position.find_by(company: position_company, fund: position_fund) if position_company && position_fund
        end

        distribution = FundDistribution.where(
          fund: fund,
          name: row["name"],
          date: row["date"]
        ).first_or_initialize
        was_new_record = distribution.new_record?

        distribution.amount = Money.new((row["amount"].to_f * 100).to_i) if row["amount"]
        distribution.notes = row["notes"]
        distribution.position = position

        was_changed = distribution.changed?
        distribution.save!

        track_record(:fund_distributions, distribution, was_changed)
        log_record_action(distribution, was_changed, "fund distribution: #{distribution.name} for #{fund.name}")
      end

      puts "Fund distributions import completed!"
    end

    # Load core_investortxn and pull into fund_investor_transactions table
    def generate_fund_investor_transactions!
      puts "Importing fund investor transactions..."

      query = <<~SQL
        SELECT it.id, it.amount, it.date, it.status,
               f.name as fund_name, i.name as investor_name,
               ba.bank_name, ba.routing_number, ba.account_number,
               fd.name as distribution_name, fd.date as distribution_date
        FROM core_investortxn it
        JOIN core_investorfundinvestment ifi ON it.investment_id = ifi.id
        JOIN core_fund f ON ifi.fund_id = f.id
        JOIN core_investor i ON ifi.investor_id = i.id
        LEFT JOIN core_bankaccount ba ON it.bank_account_id = ba.id
        LEFT JOIN core_funddistribution fd ON it.distribution_id = fd.id
        ORDER BY it.id
      SQL

      result = postgres_connection.exec(query)

      result.each do |row|
        fund = Fund.find_by(name: row["fund_name"])
        investor_account = InvestorAccount.find_by(name: row["investor_name"])

        next unless fund && investor_account

        # Find the fund investor investment
        fund_investor_investment = FundInvestorInvestment.find_by(fund: fund, investor_account: investor_account)
        next unless fund_investor_investment

        # Find bank account if specified
        bank_account = nil
        if row["bank_name"] && row["routing_number"] && row["account_number"]
          bank_account = BankAccount.where(
            account: investor_account
          ).where(
            "metadata->>'routing_number' = ? AND metadata->>'account_number' = ?",
            row["routing_number"],
            row["account_number"]
          ).first
        end

        # Find fund distribution if specified
        fund_distribution = nil
        if row["distribution_name"] && row["distribution_date"]
          fund_distribution = FundDistribution.find_by(
            fund: fund,
            name: row["distribution_name"],
            date: row["distribution_date"]
          )
        end

        money_amount = (row["amount"].to_f * 100).to_i

        transaction = FundInvestorTransaction.where(
          fund_investor_investment: fund_investor_investment,
          date: row["date"],
          amount_cents: money_amount
        ).first_or_initialize
        was_new_record = transaction.new_record?

        transaction.amount = Money.new(money_amount)
        transaction.bank_account = bank_account
        transaction.fund_distribution = fund_distribution

        # Map status string to enum
        case row["status"]&.downcase
        when "pending"
          transaction.status = :PENDING
        when "complete", "completed"
          transaction.status = :COMPLETE
        else
          # If status is already an integer, map directly
          case row["status"]&.to_i
          when 0
            transaction.status = :PENDING
          when 1
            transaction.status = :COMPLETE
          end
        end

        was_changed = transaction.changed?
        transaction.save!

        track_record(:fund_investor_transactions, transaction, was_changed)
        log_record_action(transaction, was_changed, "transaction: #{investor_account.name} in #{fund.name}")
      end

      puts "Fund investor transactions import completed!"
    end

    def initialize_stats(model_name)
      @stats[model_name] = { created: 0, updated: 0 }
    end

    def track_record(model_name, record, was_changed = false)
      initialize_stats(model_name) unless @stats[model_name]

      if record.previously_new_record?
        @stats[model_name][:created] += 1
      elsif was_changed
        @stats[model_name][:updated] += 1
      end
    end

    def log_record_action(record, was_changed, message)
      if record.previously_new_record?
        puts "  Created #{message}"
      elsif was_changed
        puts "  Updated #{message}"
      end
    end

    def print_import_summary
      puts "\n📊 Import Summary:"
      puts "=" * 50

      total_created = 0
      total_updated = 0

      @stats.each do |model_name, stats|
        created = stats[:created]
        updated = stats[:updated]
        total = created + updated

        total_created += created
        total_updated += updated

        puts "#{model_name.to_s.capitalize.ljust(15)}: #{total.to_s.rjust(3)} total (#{created} created, #{updated} updated)"
      end

      puts "-" * 50
      puts "#{'Total'.ljust(15)}: #{(total_created + total_updated).to_s.rjust(3)} total (#{total_created} created, #{total_updated} updated)"
    end

    def find_or_create_location(city, region, country)
      return nil if city.nil? && region.nil? && country.nil?

      location = Location.where(city: city, region: region, country: country).first_or_initialize
      location.slug = [ city, region, country ].compact.join("-").parameterize if location.new_record?
      location.save!

      track_record(:locations, location) if location.previously_new_record?
      location
    end

    def import_database_documents!
      puts "  Checking for documents in PostgreSQL database..."

      query = <<~SQL
        SELECT d.id, d.name, d.date, d.file,
               f.name as firm_name, fund.name as fund_name,
               c.name as company_name, i.name as investor_name
        FROM core_document d
        LEFT JOIN core_firm f ON d.firm_id = f.id
        LEFT JOIN core_fund fund ON d.fund_id = fund.id
        LEFT JOIN core_company c ON d.company_id = c.id
        LEFT JOIN core_investor i ON d.investor_id = i.id
        ORDER BY d.id
      SQL

      begin
        result = postgres_connection.exec(query)

        if result.ntuples == 0
          puts "  No documents found in PostgreSQL database"
          return []
        end

        imported_files = []

        result.each do |row|
          firm_account = FirmAccount.find_by(name: row["firm_name"]) if row["firm_name"]
          fund = Fund.find_by(name: row["fund_name"]) if row["fund_name"]
          company = Company.find_by(name: row["company_name"]) if row["company_name"]
          investor_account = InvestorAccount.find_by(name: row["investor_name"]) if row["investor_name"]

          # Debug: Show what we got from database
          puts "  🔍 Processing: '#{row['name']}' with date '#{row['date']}' (#{row['date'].class})"

          # Skip if we can't find any associations
          next unless firm_account || fund || company || investor_account

          # Try to find the actual file in the docs folder
          file_path = find_file_by_name(docs_folder, row["name"])

          if file_path
            # Parse and validate the date from database
            document_date = begin
              if row["date"].present?
                # Handle different date formats from PostgreSQL
                case row["date"]
                when Date
                  row["date"]
                when String
                  Date.parse(row["date"])
                else
                  puts "  ⚠️  Unexpected date type #{row['date'].class} for '#{row['name']}': #{row['date']}"
                  Date.parse(row["date"].to_s)
                end
              else
                puts "  ⚠️  No date provided for document '#{row['name']}', using current date"
                Date.current
              end
            rescue ArgumentError => e
              puts "  ⚠️  Invalid date '#{row['date']}' for document '#{row['name']}': #{e.message}, using current date"
              Date.current
            end

            # Try to find existing document by name and date, handling case variations
            document = Document.where(
              "LOWER(name) = LOWER(?)",
              row["name"]
            ).first

            # If not found, create new one with original name from database
            if document
              # Update existing document with database date
              old_date = document.date
              document.date = document_date
              if old_date != document_date
                puts "  📅 Updated date for '#{document.name}' from #{old_date} to #{document_date}"
              end
            else
              document = Document.new(
                name: row["name"],
                date: document_date
              )
              puts "  📝 Creating new document '#{row['name']}' with date #{document_date}"
            end

            was_new_record = document.new_record?

            document.firm_account = firm_account if firm_account
            document.fund = fund if fund
            document.company = company if company
            document.investor_account = investor_account if investor_account

            # Attach the file if we found it and document doesn't already have a file
            if file_path && !document.file.attached?
              begin
                document.file.attach(
                  io: File.open(file_path),
                  filename: File.basename(file_path),
                  content_type: determine_content_type(file_path)
                )
              rescue => e
                puts "  ⚠️  Failed to attach file #{file_path}: #{e.message}"
              end
            end

            was_changed = document.changed?

            # Only save if we have required fields and at least one association
            if document.name.present? && document.date.present? && (firm_account || fund || company || investor_account)
              begin
                document.save!
                track_record(:documents, document, was_changed)
                log_record_action(document, was_changed, "document: #{document.name}")
                imported_files << file_path if file_path
              rescue => e
                puts "  ⚠️  Failed to save document #{document.name}: #{e.message}"
              end
            end
          else
            puts "  ⚠️  Could not find file for document: #{row['name']}"
          end
        end

        imported_files
      rescue PG::UndefinedTable => e
        puts "  No core_document table found in PostgreSQL database"
        []
      rescue => e
        puts "  Error importing database documents: #{e.message}"
        []
      end
    end

    def import_filesystem_documents!(already_imported_files)
      puts "  Checking for unmatched files in file system..."

      return unless Dir.exist?(docs_folder)

      all_files = Dir.glob(File.join(docs_folder, "**", "*")).select { |f| File.file?(f) }
      importable_files = all_files.select { |f| importable_file?(f) }
      unmatched_files = importable_files - already_imported_files

      puts "  📁 File system summary:"
      puts "    - Total files in docs folder: #{all_files.length}"
      puts "    - Importable files: #{importable_files.length}"
      puts "    - Database-linked documents: #{already_imported_files.length}"
      puts "    - Unmatched files: #{unmatched_files.length}"

      if unmatched_files.any?
        puts "  ⚠️  Unmatched files (not in database):"
        unmatched_files.first(10).each do |file|
          puts "    - #{File.basename(file)}"
        end
        puts "    - ... and #{unmatched_files.length - 10} more files" if unmatched_files.length > 10
      end
    end

    def importable_file?(file_path)
      # Define which file types we want to import
      allowed_extensions = %w[.pdf .doc .docx .xls .xlsx .txt .jpg .jpeg .png .gif]
      extension = File.extname(file_path).downcase

      return false unless allowed_extensions.include?(extension)

      # Skip hidden files and system files
      filename = File.basename(file_path)
      return false if filename.start_with?(".")
      return false if filename.include?("~") # Skip temporary files

      true
    end

    def find_file_by_name(docs_folder, document_name)
      return nil unless Dir.exist?(docs_folder)

      # Try exact match first (with and without extension)
      potential_filenames = [
        document_name,
        "#{document_name}.pdf",
        "#{document_name}.doc",
        "#{document_name}.docx"
      ]

      potential_filenames.each do |filename|
        file_path = File.join(docs_folder, filename)
        return file_path if File.exist?(file_path)
      end

      # Try case-insensitive search
      Dir.glob(File.join(docs_folder, "**", "*")).each do |file_path|
        next if File.directory?(file_path)

        basename = File.basename(file_path, File.extname(file_path))
        if basename.downcase == document_name.downcase
          return file_path
        end
      end

      nil
    end

    def determine_content_type(file_path)
      extension = File.extname(file_path).downcase

      case extension
      when ".pdf"
        "application/pdf"
      when ".doc"
        "application/msword"
      when ".docx"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      when ".xls"
        "application/vnd.ms-excel"
      when ".xlsx"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      when ".txt"
        "text/plain"
      when ".jpg", ".jpeg"
        "image/jpeg"
      when ".png"
        "image/png"
      when ".gif"
        "image/gif"
      else
        "application/octet-stream"
      end
    end
  end
end
