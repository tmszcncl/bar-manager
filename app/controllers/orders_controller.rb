class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_products, only: [:new, :edit, :update]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new(step: Order::STEPS.first)
    3.times { @order.order_items.build(quantity: 0) }
  end

  def edit
    3.times { @order.order_items.build(quantity: 0) }
  end

  def create
    @order = Order.new(order_params)
    @order.remove_invalid_order_items

    add_new_item_from_create if params[:add_new_item]
    transfer_to_kitchen_from_create if params[:commit] == 'Transfer to Kitchen'
  end

  def queued
    @orders = Order.where(step: 'queued')
  end

  def update
    @order.remove_invalid_order_items
    remove_zombie_order_items
    new_order_params = clean_order_params

    add_new_item_from_update(new_order_params) if params[:add_new_item]
    transfer_to_kitchen_from_update(new_order_params) if params[:commit] == 'Transfer to Kitchen'
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def set_products
    @products = Product.cached_products
  end

  def order_params
    params.require(:order).permit(:step, order_items_attributes: [:id, :product_id, :order_id, :quantity])
  end

  def remove_zombie_order_items
    atts = order_params['order_items_attributes']
    zombies = atts.select { |_, v| v['quantity'].to_i.zero? && !v['product_id'].blank? }
    if zombies
      zombies = zombies.map { |_, v| v[:id] }
      zombies.each { |z| OrderItem.find(z).delete }
    end
  end

  def clean_order_params
    new_order_params = order_params.dup
    new_order_params['order_items_attributes'].delete_if do |_, v|
      v['quantity'].to_i.zero? || v['product_id'].to_i.zero?
    end
    new_order_params
  end

  def transfer_to_kitchen_from_create
    @order.step = 'queued'
    @order.save
    ActionCable.server.broadcast 'notification_channel', info: 'Order sent to Kitchen'
    redirect_to new_order_path
  end

  def add_new_item_from_create
    @order.save
    redirect_to edit_order_path(@order)
  end

  def transfer_to_kitchen_from_update(new_order_params)
    @order.step = 'queued'
    @order.update(new_order_params)
    redirect_to new_order_path
  end

  def add_new_item_from_update(new_order_params)
    @order.update(new_order_params)
    redirect_to edit_order_path(@order)
  end
end
