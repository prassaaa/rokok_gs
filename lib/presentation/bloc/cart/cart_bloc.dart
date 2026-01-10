import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/transaction/create_transaction.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// BLoC for managing shopping cart and transaction submission
class CartBloc extends Bloc<CartEvent, CartState> {
  final CreateTransaction createTransaction;

  CartBloc({
    required this.createTransaction,
  }) : super(const CartActive()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<IncrementCartItem>(_onIncrementCartItem);
    on<DecrementCartItem>(_onDecrementCartItem);
    on<UpdateCustomerInfo>(_onUpdateCustomerInfo);
    on<UpdateCustomerContact>(_onUpdateCustomerContact);
    on<UpdateLocation>(_onUpdateLocation);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<UpdateCartArea>(_onUpdateCartArea);
    on<UpdateDiscount>(_onUpdateDiscount);
    on<UpdateNotes>(_onUpdateNotes);
    on<ClearCart>(_onClearCart);
    on<SubmitTransaction>(_onSubmitTransaction);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final existingIndex = currentState.items
        .indexWhere((item) => item.product.id == event.product.id);

    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update existing item quantity
      updatedItems = currentState.items.map((item) {
        if (item.product.id == event.product.id) {
          return item.copyWith(
            quantity: item.quantity + event.quantity,
            price: event.customPrice ?? item.price,
          );
        }
        return item;
      }).toList();
    } else {
      // Add new item
      updatedItems = [
        ...currentState.items,
        CartItem(
          product: event.product,
          quantity: event.quantity,
          price: event.customPrice ?? event.product.price,
        ),
      ];
    }

    emit(currentState.copyWith(items: updatedItems, clearError: true));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final updatedItems = currentState.items
        .where((item) => item.product.id != event.productId)
        .toList();

    emit(currentState.copyWith(items: updatedItems, clearError: true));
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    if (event.quantity <= 0) {
      add(RemoveFromCart(event.productId));
      return;
    }

    final updatedItems = currentState.items.map((item) {
      if (item.product.id == event.productId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems, clearError: true));
  }

  void _onIncrementCartItem(IncrementCartItem event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final item = currentState.getItem(event.productId);
    if (item != null) {
      add(UpdateCartItemQuantity(
        productId: event.productId,
        quantity: item.quantity + 1,
      ));
    }
  }

  void _onDecrementCartItem(DecrementCartItem event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final item = currentState.getItem(event.productId);
    if (item != null) {
      if (item.quantity <= 1) {
        add(RemoveFromCart(event.productId));
      } else {
        add(UpdateCartItemQuantity(
          productId: event.productId,
          quantity: item.quantity - 1,
        ));
      }
    }
  }

  void _onUpdateCustomerInfo(
    UpdateCustomerInfo event,
    Emitter<CartState> emit,
  ) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      customerId: event.customerId,
      customerName: event.customerName,
      clearCustomerId: event.customerId == null,
      clearCustomerName: event.customerName == null,
    ));
  }

  void _onUpdateCustomerContact(
    UpdateCustomerContact event,
    Emitter<CartState> emit,
  ) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      customerPhone: event.customerPhone,
      customerAddress: event.customerAddress,
      clearCustomerPhone: event.customerPhone == null || event.customerPhone!.isEmpty,
      clearCustomerAddress: event.customerAddress == null || event.customerAddress!.isEmpty,
    ));
  }

  void _onUpdateLocation(
    UpdateLocation event,
    Emitter<CartState> emit,
  ) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      latitude: event.latitude,
      longitude: event.longitude,
      clearLocation: event.latitude == null && event.longitude == null,
    ));
  }

  void _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<CartState> emit,
  ) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      paymentMethod: event.paymentMethod,
      clearError: true,
    ));
  }

  void _onUpdateCartArea(UpdateCartArea event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      areaId: event.areaId,
      clearAreaId: event.areaId == null,
    ));
  }

  void _onUpdateDiscount(UpdateDiscount event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(discount: event.discount));
  }

  void _onUpdateNotes(UpdateNotes event, Emitter<CartState> emit) {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    emit(currentState.copyWith(
      notes: event.notes,
      clearNotes: event.notes == null || event.notes!.isEmpty,
    ));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartActive());
  }

  Future<void> _onSubmitTransaction(
    SubmitTransaction event,
    Emitter<CartState> emit,
  ) async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    if (currentState.isEmpty) {
      emit(currentState.copyWith(error: 'Keranjang kosong'));
      return;
    }

    if (currentState.customerName == null || currentState.customerName!.isEmpty) {
      emit(currentState.copyWith(error: 'Nama pelanggan wajib diisi'));
      return;
    }

    if (currentState.paymentMethod == null) {
      emit(currentState.copyWith(error: 'Pilih metode pembayaran'));
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearError: true));

    final result = await createTransaction(currentState.toTransactionParams());

    result.fold(
      (failure) => emit(CartSubmissionError(
        message: failure.message,
        previousState: currentState.copyWith(isSubmitting: false),
      )),
      (transaction) => emit(CartSubmitted(transaction)),
    );
  }

  CartActive? _getCurrentState() {
    if (state is CartActive) {
      return state as CartActive;
    }
    if (state is CartSubmissionError) {
      return (state as CartSubmissionError).previousState;
    }
    return null;
  }

  /// Reset cart after error - call using add event
  void resetFromError() {
    if (state is CartSubmissionError) {
      // Use add to trigger state change through event system
      add(const ClearCart());
    }
  }
}
