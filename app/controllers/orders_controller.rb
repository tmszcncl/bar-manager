class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :next_step]
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
    transfer_to_kitchen_from_create if params[:transfer_to_kitchen]
    destroy if params[:delete_order]
  end

  def queued
    @orders = Order.where(step: 'queued')
  end

  def in_progress
    @orders = Order.where(step: 'in_progress')
  end

  def ready
    @orders = Order.where(step: 'ready')
  end

  def released
    @orders = Order.where(step: 'released')
  end

  def update
    @order.remove_invalid_order_items
    remove_zombie_order_items
    new_order_params = clean_order_params

    add_new_item_from_update(new_order_params) if params[:add_new_item]
    transfer_to_kitchen_from_update(new_order_params) if params[:transfer_to_kitchen]
    destroy if params[:delete_order]
  end

  def destroy
    @order.destroy
    redirect_to new_order_path if params[:action] == 'edit'
    redirect_to :back
  end

  def next_step
    current_index = Order::STEPS.index(@order.step)
    @order.step = Order::STEPS[current_index + 1]
    @order.save
    redirect_to :back
  end

  private
  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_order_path
  end

  def set_products
    @products = Product.cached_products
  end

  def order_params
    params.require(:order)
          .permit(:step,
                  order_items_attributes: [
                    :id,
                    :product_id,
                    :order_id,
                    :quantity,
                    :transfer_to_kitchen,
                    :add_new_item
                  ])
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
