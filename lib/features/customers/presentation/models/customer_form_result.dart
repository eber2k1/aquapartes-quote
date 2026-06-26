import '../../domain/entities/customer.dart';

class CustomerFormResult {
  const CustomerFormResult._({this.customer, this.deleted = false});

  const CustomerFormResult.saved(Customer customer)
    : this._(customer: customer);

  const CustomerFormResult.deleted() : this._(deleted: true);

  final Customer? customer;
  final bool deleted;
}
