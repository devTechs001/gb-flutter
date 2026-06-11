import 'package:flutter/material.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (value.length > 30) return 'Name must be less than 30 characters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Invalid phone number';
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length < 6) return 'OTP must be 6 digits';
    return null;
  }

  static String? validateGroupName(String? value) {
    if (value == null || value.isEmpty) return 'Group name is required';
    if (value.length < 3) return 'Group name must be at least 3 characters';
    if (value.length > 100) return 'Group name must be less than 100 characters';
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 4096) return 'Message too long';
    return null;
  }

  static String? validateStatus(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 139) return 'Status must be less than 139 characters';
    return null;
  }
}
