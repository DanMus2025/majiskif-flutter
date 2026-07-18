import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';

class MajiskifApp extends StatelessWidget {
  const MajiskifApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KESE',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEC6A2B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFAF4),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: BootstrapGate(controller: controller),
    );
  }
}

class BootstrapGate extends StatefulWidget {
  const BootstrapGate({super.key, required this.controller});

  final AppController controller;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  late final Future<void> _bootstrap = widget.controller.bootstrap();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        return ValueListenableBuilder<AppPhase>(
          valueListenable: widget.controller.phase,
          builder: (context, phase, _) {
            return switch (phase) {
              AppPhase.needLicense => ActivationPage(
                controller: widget.controller,
              ),
              AppPhase.needSetup => SetupPage(controller: widget.controller),
              AppPhase.needLogin => LoginPage(controller: widget.controller),
              AppPhase.ready => ShellPage(controller: widget.controller),
              AppPhase.loading => const _SplashScreen(),
            };
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de KESE...'),
          ],
        ),
      ),
    );
  }
}

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _ownerController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _licenseController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Activation de licence',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'La licence est mémorisée localement et validée au démarrage.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _licenseController,
                        decoration: const InputDecoration(
                          labelText: 'Clé de licence',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'La clé est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ownerController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du client',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Le client est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Activer et continuer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.activateLicense(
        licenseKey: _licenseController.text,
        ownerName: _ownerController.text,
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Administrateur');
  final _emailController = TextEditingController(text: 'admin@kese.local');
  final _passwordController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Création du compte administrateur',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucun utilisateur n’existe encore pour cette licence.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Le nom est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'L’e-mail est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                        ),
                        obscureText: true,
                        validator: (value) =>
                            (value == null || value.length < 4)
                            ? 'Le mot de passe doit contenir au moins 4 caractères'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Créer et ouvrir la session'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.createInitialAdmin(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@kese.local');
  final _passwordController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connexion',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'La licence est déjà validée. Connectez-vous pour accéder à l’application.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'L’e-mail est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                        ),
                        obscureText: true,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Le mot de passe est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(controller: widget.controller),
      SalesPage(controller: widget.controller),
      PurchasesPage(controller: widget.controller),
      StockPage(controller: widget.controller),
      PartnersPage(controller: widget.controller),
      SettingsPage(controller: widget.controller),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('KESE'),
        actions: [
          ValueListenableBuilder<String?>(
            valueListenable: widget.controller.syncMessage,
            builder: (context, message, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: Text(message ?? 'Prêt')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Ventes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Achats',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Partenaires',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardSnapshot>(
      valueListenable: controller.dashboard,
      builder: (context, snapshot, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MetricGrid(snapshot: snapshot),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'Ventes sur 7 jours',
              values: snapshot.recentDailySales,
              color: const Color(0xFFEC6A2B),
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'Achats sur 7 jours',
              values: snapshot.recentDailyPurchases,
              color: const Color(0xFF2A7B9B),
            ),
          ],
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Ventes', snapshot.totalSales, Icons.point_of_sale),
      ('Bénéfice', snapshot.totalProfit, Icons.trending_up),
      ('Achats', snapshot.totalPurchases, Icons.shopping_cart),
      ('Stock', snapshot.stockValue, Icons.inventory_2),
      ('Crédit', snapshot.creditBalance, Icons.payments),
      ('Stock bas', snapshot.lowStockCount.toDouble(), Icons.warning_amber),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (card) => SizedBox(
              width: 160,
              child: _MetricCard(title: card.$1, value: card.$2, icon: card.$3),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value.toStringAsFixed(2),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(0, math.max);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final value in values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: maxValue <= 0
                              ? 6
                              : (140 * (value / maxValue)).clamp(6, 140),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String? _selectedProductId;
  final List<SaleLineItem> _lines = [];
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _customerName.dispose();
    _customerPhone.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductItem>>(
      valueListenable: widget.controller.products,
      builder: (context, products, _) {
        _selectedProductId ??= products.isEmpty ? null : products.first.id;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormCard(
              title: 'Nouvelle vente',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _customerName,
                    decoration: const InputDecoration(labelText: 'Client'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerPhone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone client',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    items: products
                        .map(
                          (product) => DropdownMenuItem(
                            value: product.id,
                            child: Text(
                              '${product.name} - stock ${product.stockQuantity.toStringAsFixed(0)}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setState(() => _selectedProductId = value),
                    decoration: const InputDecoration(labelText: 'Produit'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix unitaire',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter la ligne'),
                  ),
                  const SizedBox(height: 16),
                  if (_lines.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final line in _lines)
                          ListTile(
                            title: Text(line.label),
                            subtitle: Text(
                              '${line.quantity.toStringAsFixed(0)} x ${line.unitPrice.toStringAsFixed(2)}',
                            ),
                            trailing: Text(line.lineTotal.toStringAsFixed(2)),
                          ),
                        const Divider(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total: ${_lines.fold<double>(0, (sum, item) => sum + item.lineTotal).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: _busy ? null : _saveSale,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer la vente'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RecordsCard(
              title: 'Historique des ventes',
              child: ValueListenableBuilder<List<SaleItem>>(
                valueListenable: widget.controller.sales,
                builder: (context, sales, _) {
                  return Column(
                    children: [
                      for (final sale in sales)
                        ListTile(
                          title: Text(
                            sale.customerName.isEmpty
                                ? 'Client'
                                : sale.customerName,
                          ),
                          subtitle: Text(
                            '${sale.lines.length} ligne(s) · ${formatDateTime(sale.createdAt)}',
                          ),
                          trailing: Text(sale.totalAmount.toStringAsFixed(2)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _addLine() {
    final productId = _selectedProductId;
    if (productId == null) return;
    final products = widget.controller.products.value;
    final product = products
        .where((item) => item.id == productId)
        .toList(growable: false)
        .first;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? product.unitPrice;
    if (quantity <= 0 || price <= 0) return;
    setState(() {
      _lines.add(
        SaleLineItem(
          productId: product.id,
          label: product.name,
          quantity: quantity,
          unitPrice: price,
        ),
      );
      _quantityController.text = '1';
      _priceController.clear();
    });
  }

  Future<void> _saveSale() async {
    if (_lines.isEmpty) {
      setState(() => _error = 'Ajoutez au moins une ligne.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final customerName = _customerName.text.trim();
      var customerId = '';
      if (customerName.isNotEmpty) {
        final existing = widget.controller.customers.value
            .where(
              (customer) =>
                  customer.name.toLowerCase() == customerName.toLowerCase(),
            )
            .toList(growable: false);
        if (existing.isNotEmpty) {
          customerId = existing.first.id;
        } else {
          final tempId = newId('customer');
          await widget.controller.addOrUpdateCustomer(
            id: tempId,
            name: customerName,
            phone: _customerPhone.text,
          );
          customerId = tempId;
        }
      }
      await widget.controller.recordSale(
        customerId: customerId,
        customerName: customerName,
        lines: List<SaleLineItem>.from(_lines),
      );
      if (mounted) {
        setState(() {
          _lines.clear();
          _customerName.clear();
          _customerPhone.clear();
        });
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _supplierName = TextEditingController();
  final _supplierPhone = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _paidController = TextEditingController(text: '0');
  final _dueDateController = TextEditingController();
  String? _selectedProductId;
  final List<PurchaseLineItem> _lines = [];
  bool _creditPurchase = false;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _supplierName.dispose();
    _supplierPhone.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _paidController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductItem>>(
      valueListenable: widget.controller.products,
      builder: (context, products, _) {
        _selectedProductId ??= products.isEmpty ? null : products.first.id;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormCard(
              title: 'Nouvel achat',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _supplierName,
                    decoration: const InputDecoration(labelText: 'Fournisseur'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _supplierPhone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone fournisseur',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    items: products
                        .map(
                          (product) => DropdownMenuItem(
                            value: product.id,
                            child: Text(
                              '${product.name} - stock ${product.stockQuantity.toStringAsFixed(0)}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setState(() => _selectedProductId = value),
                    decoration: const InputDecoration(labelText: 'Produit'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix unitaire',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter la ligne'),
                  ),
                  const SizedBox(height: 16),
                  if (_lines.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final line in _lines)
                          ListTile(
                            title: Text(line.label),
                            subtitle: Text(
                              '${line.quantity.toStringAsFixed(0)} x ${line.unitPrice.toStringAsFixed(2)}',
                            ),
                            trailing: Text(line.lineTotal.toStringAsFixed(2)),
                          ),
                        const Divider(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total: ${_lines.fold<double>(0, (sum, item) => sum + item.lineTotal).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _creditPurchase,
                    onChanged: (value) =>
                        setState(() => _creditPurchase = value),
                    title: const Text('Achat à crédit'),
                    subtitle: const Text(
                      'Désactiver pour un paiement immédiat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _paidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Montant payé',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Échéance (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Builder(
                    builder: (context) {
                      final total = _lines.fold<double>(
                        0,
                        (sum, item) => sum + item.lineTotal,
                      );
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total calculé'),
                            Text(
                              total.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _savePurchase,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer l’achat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RecordsCard(
              title: 'Crédit fournisseurs',
              child: ValueListenableBuilder<List<PurchaseItem>>(
                valueListenable: widget.controller.purchases,
                builder: (context, purchases, _) {
                  return Column(
                    children: [
                      for (final purchase in purchases)
                        Card(
                          child: ListTile(
                            title: Text(
                              purchase.supplierName.isEmpty
                                  ? 'Fournisseur'
                                  : purchase.supplierName,
                            ),
                            subtitle: Text(
                              '${purchase.paymentStatus.label} · reste ${purchase.remainingAmount.toStringAsFixed(2)}',
                            ),
                            trailing: TextButton(
                              onPressed: purchase.remainingAmount <= 0
                                  ? null
                                  : () => _payPurchase(purchase),
                              child: const Text('Payer'),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _addLine() {
    final productId = _selectedProductId;
    if (productId == null) return;
    final products = widget.controller.products.value;
    final product = products
        .where((item) => item.id == productId)
        .toList(growable: false)
        .first;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? product.unitPrice;
    if (quantity <= 0 || price <= 0) return;
    setState(() {
      _lines.add(
        PurchaseLineItem(
          productId: product.id,
          label: product.name,
          quantity: quantity,
          unitPrice: price,
        ),
      );
      _quantityController.text = '1';
      _priceController.clear();
    });
  }

  Future<void> _savePurchase() async {
    if (_lines.isEmpty) {
      setState(() => _error = 'Ajoutez au moins une ligne.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final supplierName = _supplierName.text.trim();
      var supplierId = '';
      if (supplierName.isNotEmpty) {
        final existing = widget.controller.suppliers.value
            .where(
              (supplier) =>
                  supplier.name.toLowerCase() == supplierName.toLowerCase(),
            )
            .toList(growable: false);
        if (existing.isNotEmpty) {
          supplierId = existing.first.id;
        } else {
          final tempId = newId('supplier');
          await widget.controller.addOrUpdateSupplier(
            id: tempId,
            name: supplierName,
            phone: _supplierPhone.text,
          );
          supplierId = tempId;
        }
      }
      final dueAt = _creditPurchase && _dueDateController.text.trim().isNotEmpty
          ? DateTime.tryParse('${_dueDateController.text.trim()}T00:00:00Z')
          : null;
      await widget.controller.recordPurchase(
        supplierId: supplierId,
        supplierName: supplierName,
        lines: List<PurchaseLineItem>.from(_lines),
        paidAmount: double.tryParse(_paidController.text) ?? 0,
        dueAt: dueAt,
      );
      if (mounted) {
        setState(() {
          _lines.clear();
          _supplierName.clear();
          _supplierPhone.clear();
          _paidController.text = '0';
          _dueDateController.clear();
          _creditPurchase = false;
        });
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _payPurchase(PurchaseItem purchase) async {
    final amountController = TextEditingController(
      text: purchase.remainingAmount.toStringAsFixed(2),
    );
    final noteController = TextEditingController(
      text: 'Règlement complémentaire',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement fournisseur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (result == true) {
      await widget.controller.addPurchasePayment(
        purchaseId: purchase.id,
        amount: double.tryParse(amountController.text) ?? 0,
        note: noteController.text,
      );
    }
  }
}

class StockPage extends StatelessWidget {
  const StockPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FormCard(
          title: 'Produit',
          child: _ProductForm(controller: controller),
        ),
        const SizedBox(height: 16),
        _RecordsCard(
          title: 'Produits en stock',
          child: ValueListenableBuilder<List<ProductItem>>(
            valueListenable: controller.products,
            builder: (context, products, _) {
              return Column(
                children: [
                  for (final product in products)
                    ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'SKU ${product.sku.isEmpty ? '—' : product.sku}',
                      ),
                      trailing: Text(
                        '${product.stockQuantity.toStringAsFixed(0)} unités',
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({required this.controller});

  final AppController controller;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _unit = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController(text: '0');
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _cost.dispose();
    _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sku,
          decoration: const InputDecoration(labelText: 'SKU'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _unit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix de vente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _cost,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Coût d’achat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _stock,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stock initial'),
        ),
        const SizedBox(height: 12),
        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer le produit'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.addOrUpdateProduct(
        name: _name.text,
        sku: _sku.text,
        unitPrice: double.tryParse(_unit.text) ?? 0,
        costPrice: double.tryParse(_cost.text) ?? 0,
        stockQuantity: double.tryParse(_stock.text) ?? 0,
      );
      if (mounted) {
        _name.clear();
        _sku.clear();
        _unit.clear();
        _cost.clear();
        _stock.text = '0';
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RecordsCard(
          title: 'Clients',
          child: ValueListenableBuilder<List<CustomerItem>>(
            valueListenable: controller.customers,
            builder: (context, customers, _) {
              return Column(
                children: [
                  for (final customer in customers)
                    ListTile(
                      title: Text(customer.name),
                      subtitle: Text(
                        customer.phone.isEmpty ? '—' : customer.phone,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _RecordsCard(
          title: 'Fournisseurs',
          child: ValueListenableBuilder<List<SupplierItem>>(
            valueListenable: controller.suppliers,
            builder: (context, suppliers, _) {
              return Column(
                children: [
                  for (final supplier in suppliers)
                    ListTile(
                      title: Text(supplier.name),
                      subtitle: Text(
                        supplier.phone.isEmpty ? '—' : supplier.phone,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _FormCard(
          title: 'Dépense',
          child: _ExpenseForm(controller: controller),
        ),
        const SizedBox(height: 16),
        _RecordsCard(
          title: 'Dépenses',
          child: ValueListenableBuilder<List<ExpenseItem>>(
            valueListenable: controller.expenses,
            builder: (context, expenses, _) {
              return Column(
                children: [
                  for (final expense in expenses)
                    ListTile(
                      title: Text(expense.label),
                      trailing: Text(expense.amount.toStringAsFixed(2)),
                      subtitle: Text(formatDateTime(expense.createdAt)),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({required this.controller});

  final AppController controller;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _label = TextEditingController();
  final _amount = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _label,
          decoration: const InputDecoration(labelText: 'Libellé'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant'),
        ),
        const SizedBox(height: 12),
        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer la dépense'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.recordExpense(
        label: _label.text,
        amount: double.tryParse(_amount.text) ?? 0,
      );
      if (mounted) {
        _label.clear();
        _amount.clear();
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FormCard(
          title: 'Licence',
          child: ValueListenableBuilder<LicenseState?>(
            valueListenable: controller.license,
            builder: (context, license, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(license == null ? 'Aucune licence' : license.licenseKey),
                  const SizedBox(height: 8),
                  Text(license == null ? '—' : 'Client: ${license.ownerName}'),
                  const SizedBox(height: 8),
                  Text(license == null ? '—' : 'Statut: ${license.status}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => controller.invalidateLicense(),
                    child: const Text('Supprimer la licence locale'),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _FormCard(
          title: 'Synchronisation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: controller.syncing,
                builder: (context, syncing, _) {
                  return FilledButton.icon(
                    onPressed: syncing ? null : () => controller.syncNow(),
                    icon: syncing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      syncing
                          ? 'Synchronisation...'
                          : 'Synchroniser maintenant',
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: controller.syncMessage,
                builder: (context, message, _) =>
                    Text(message ?? 'Aucun message de synchronisation'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormCard(
          title: 'Compte',
          child: ValueListenableBuilder<AppSession?>(
            valueListenable: controller.session,
            builder: (context, session, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(session == null ? '—' : session.user.name),
                  const SizedBox(height: 8),
                  Text(session == null ? '—' : session.user.email),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => controller.signOut(),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
