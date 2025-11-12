import 'package:flutter/material.dart';
import 'package:festeasy_app/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  static const String routeName = '/payment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Implement navigation
          },
        ),
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const OrderSummaryCard(),
              const SizedBox(height: 24),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const PaymentMethodSelector(),
              const SizedBox(height: 24),
              const CardDetailsForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PaymentFooter(),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          const OrderSummaryItem(
            title: 'DJ Beats',
            category: 'DJ',
            price: '\$250.00',
          ),
          const Divider(height: 1),
          const OrderSummaryItem(
            title: 'Catering Delights',
            category: 'Caterer',
            price: '\$400.00',
          ),
          const Divider(height: 1),
          const OrderSummaryItem(
            title: 'Event Space',
            category: 'Venue',
            price: '\$1500.00',
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const TotalRow(label: 'Subtotal', amount: '\$2150.00'),
                const SizedBox(height: 8),
                const TotalRow(label: 'Taxes & Fees', amount: '\$150.00'),
                const Divider(height: 24),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!,
                  child: const TotalRow(label: 'Total', amount: '\$2300.00'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryItem extends StatelessWidget {
  const OrderSummaryItem({
    required this.title,
    required this.category,
    required this.price,
    super.key,
  });

  final String title;
  final String category;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(
                category,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Text(price, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class TotalRow extends StatelessWidget {
  const TotalRow({required this.label, required this.amount, super.key});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(amount),
      ],
    );
  }
}

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  int _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaymentMethodTile(
          title: 'Credit Card',
          icon: Icons.credit_card,
          value: 0,
          groupValue: _selectedMethod,
          onChanged: (value) => setState(() => _selectedMethod = value!),
        ),
        const SizedBox(height: 12),
        PaymentMethodTile(
          title: 'PayPal',
          imageAsset: 'assets/paypal_logo.png', // TODO: Add paypal logo
          value: 1,
          groupValue: _selectedMethod,
          onChanged: (value) => setState(() => _selectedMethod = value!),
        ),
        const SizedBox(height: 12),
        PaymentMethodTile(
          title: 'Bank Transfer',
          icon: Icons.account_balance,
          value: 2,
          groupValue: _selectedMethod,
          onChanged: (value) => setState(() => _selectedMethod = value!),
        ),
      ],
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    required this.title,
    this.icon,
    this.imageAsset,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final String title;
  final IconData? icon;
  final String? imageAsset;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: Theme.of(context).colorScheme.primary)
            else if (imageAsset != null)
              // TODO: Replace with actual image
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCaxRy4dJFCtSAp0HLTNH-o089Xw8AWy902MnT316jLkGQV3eeLXP6N5YnarQ0kf4ml3OEb-nw2Fck5pQkpmCaVwhJNiTF4eM-genT_N3IuXX8Ze7oISeKtGl9Ol9rLpPpocdlEobIR_Enkgzkdw-zN5jFKgkjj9e7ZxgBAmSRDSRkp5DUgoGz5e8cYeL4XOP7loi8MNFFqDfm1mX-flG4J5I7PUDE49HwZvliyhGBRtgG-4-LxxXu1GY7q0HHnxgZ332jqeZaaBe0',
                height: 24,
                width: 24,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class CardDetailsForm extends StatelessWidget {
  const CardDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Card Number'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'MM / YY'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'CVV'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Cardholder Name'),
        ),
      ],
    );
  }
}

class PaymentFooter extends StatelessWidget {
  const PaymentFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement payment logic
          },
          icon: const Icon(Icons.lock),
          label: const Text('Pay Securely \$2300.00'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
